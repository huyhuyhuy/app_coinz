import '../database/database_helper.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import 'transaction_repository.dart';

/// Wallet Repository - Quản lý ví coin (local + server)
class WalletRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TransactionRepository _transactionRepo = TransactionRepository();
  
  // ============================================================================
  // LOCAL DATABASE OPERATIONS
  // ============================================================================
  
  /// Get wallet from local database by userId
  Future<WalletModel?> getLocalWallet(String userId) async {
    try {
      final result = await _dbHelper.queryOne(
        'wallets',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (result == null) return null;
      return WalletModel.fromMap(result);
    } catch (e) {
      print('[WALLET_REPO] ❌ Error getting local wallet: $e');
      return null;
    }
  }
  
  /// Save wallet to local database
  Future<bool> saveLocalWallet(WalletModel wallet) async {
    try {
      await _dbHelper.insert('wallets', wallet.toMap());
      print('[WALLET_REPO] ✅ Wallet saved to local database');
      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error saving local wallet: $e');
      return false;
    }
  }
  
  /// Update wallet in local database
  Future<bool> updateLocalWallet(WalletModel wallet) async {
    try {
      await _dbHelper.update(
        'wallets',
        wallet.toMap(),
        where: 'user_id = ?',
        whereArgs: [wallet.userId],
      );
      print('[WALLET_REPO] ✅ Wallet updated in local database');
      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error updating local wallet: $e');
      return false;
    }
  }
  
  /// Update wallet balance
  Future<bool> updateBalance(String userId, double amount, {bool isAdd = true}) async {
    try {
      final wallet = await getLocalWallet(userId);
      if (wallet == null) {
        print('[WALLET_REPO] ❌ Wallet not found');
        return false;
      }

      final newBalance = isAdd ? wallet.balance + amount : wallet.balance - amount;
      if (newBalance < 0) {
        print('[WALLET_REPO] ❌ Insufficient balance');
        return false;
      }

      final updatedWallet = wallet.copyWith(
        balance: newBalance,
        totalEarned: isAdd ? wallet.totalEarned + amount : wallet.totalEarned,
        totalSpent: !isAdd ? wallet.totalSpent + amount : wallet.totalSpent,
        updatedAt: DateTime.now(),
      );

      // Update local
      await updateLocalWallet(updatedWallet);
      print('[WALLET_REPO] ✅ Balance updated locally: $newBalance');

      // Sync to server (async, don't wait)
      updateServerWallet(updatedWallet).then((_) {
        print('[WALLET_REPO] ✅ Balance synced to server: $newBalance');
      }).catchError((e) {
        print('[WALLET_REPO] ⚠️ Failed to sync balance to server: $e');
      });

      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error updating balance: $e');
      return false;
    }
  }
  
  // ============================================================================
  // SERVER DATABASE OPERATIONS
  // ============================================================================
  
  /// Get wallet from server by userId
  Future<WalletModel?> getServerWallet(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .single();
      
      print('[WALLET_REPO] ✅ Wallet fetched from server');
      return WalletModel.fromJson(response);
    } catch (e) {
      print('[WALLET_REPO] ❌ Error getting server wallet: $e');
      return null;
    }
  }
  
  /// Create wallet on server
  Future<WalletModel?> createServerWallet(WalletModel wallet) async {
    try {
      final response = await SupabaseService.client
          .from('wallets')
          .insert(wallet.toJson())
          .select()
          .single();
      
      print('[WALLET_REPO] ✅ Wallet created on server');
      return WalletModel.fromJson(response);
    } catch (e) {
      print('[WALLET_REPO] ❌ Error creating server wallet: $e');
      return null;
    }
  }
  
  /// Update wallet on server
  Future<bool> updateServerWallet(WalletModel wallet) async {
    try {
      await SupabaseService.client
          .from('wallets')
          .update(wallet.toJson())
          .eq('user_id', wallet.userId);
      
      print('[WALLET_REPO] ✅ Wallet updated on server');
      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error updating server wallet: $e');
      return false;
    }
  }
  
  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================
  
  /// Sync wallet from server to local
  Future<bool> syncWalletFromServer(String userId) async {
    try {
      print('[WALLET_REPO] 🔄 Syncing wallet from server...');
      
      final serverWallet = await getServerWallet(userId);
      if (serverWallet == null) {
        print('[WALLET_REPO] ❌ Wallet not found on server');
        return false;
      }
      
      final localWallet = await getLocalWallet(userId);
      if (localWallet == null) {
        await saveLocalWallet(serverWallet);
      } else {
        await updateLocalWallet(serverWallet);
      }
      
      print('[WALLET_REPO] ✅ Wallet synced from server');
      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error syncing wallet from server: $e');
      return false;
    }
  }
  
  /// Sync wallet from local to server
  Future<bool> syncWalletToServer(String userId) async {
    try {
      print('[WALLET_REPO] 🔄 Syncing wallet to server...');
      
      final localWallet = await getLocalWallet(userId);
      if (localWallet == null) {
        print('[WALLET_REPO] ❌ Wallet not found in local database');
        return false;
      }
      
      final serverWallet = await getServerWallet(userId);
      if (serverWallet == null) {
        await createServerWallet(localWallet);
      } else {
        await updateServerWallet(localWallet);
      }
      
      print('[WALLET_REPO] ✅ Wallet synced to server');
      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error syncing wallet to server: $e');
      return false;
    }
  }
  
  // ============================================================================
  // WALLET OPERATIONS
  // ============================================================================
  
  /// Create wallet for new user
  Future<WalletModel?> createWallet(String userId) async {
    try {
      print('[WALLET_REPO] 💰 Creating wallet for user: $userId');
      
      final wallet = WalletModel(
        userId: userId,
        walletAddress: _generateWalletAddress(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to server
      final serverWallet = await createServerWallet(wallet);
      if (serverWallet == null) {
        print('[WALLET_REPO] ❌ Failed to create wallet on server');
        return null;
      }
      
      // Save to local
      await saveLocalWallet(serverWallet);
      
      print('[WALLET_REPO] ✅ Wallet created successfully');
      return serverWallet;
    } catch (e) {
      print('[WALLET_REPO] ❌ Error creating wallet: $e');
      return null;
    }
  }
  
  /// Add coins to wallet (from mining)
  Future<bool> addCoins(String userId, double amount) async {
    return await updateBalance(userId, amount, isAdd: true);
  }
  
  /// Subtract coins from wallet (for withdrawal/transfer)
  Future<bool> subtractCoins(String userId, double amount) async {
    return await updateBalance(userId, amount, isAdd: false);
  }

  /// ✅ FIX: Transfer coins between users (internal transfer)
  /// Cập nhật đồng bộ cả LOCAL và SERVER, tạo transaction history
  Future<bool> transferInternal({
    required String fromUserId,
    required String toWalletAddress,
    required double amount,
  }) async {
    try {
      print('[WALLET_REPO] 💸 Starting internal transfer...');
      print('[WALLET_REPO] From User ID: $fromUserId');
      print('[WALLET_REPO] To Wallet: $toWalletAddress');
      print('[WALLET_REPO] Amount: $amount DFI');

      // ========== STEP 1: Validate sender ==========
      final senderWallet = await getLocalWallet(fromUserId);
      if (senderWallet == null) {
        print('[WALLET_REPO] ❌ Sender wallet not found');
        return false;
      }

      // Check balance
      if (senderWallet.balance < amount) {
        print('[WALLET_REPO] ❌ Insufficient balance: ${senderWallet.balance} < $amount');
        return false;
      }

      // ========== STEP 2: Find recipient FROM SERVER (quan trọng!) ==========
      print('[WALLET_REPO] 🔍 Looking up recipient wallet on SERVER...');
      WalletModel? recipientWallet;
      
      try {
        final response = await SupabaseService.client
            .from('wallets')
            .select()
            .eq('wallet_address', toWalletAddress)
            .single();
        
        recipientWallet = WalletModel.fromJson(response);
        print('[WALLET_REPO] ✅ Found recipient: ${recipientWallet.userId}');
      } catch (e) {
        print('[WALLET_REPO] ❌ Recipient wallet not found on server: $e');
        return false;
      }

      // Prevent self-transfer
      if (senderWallet.userId == recipientWallet.userId) {
        print('[WALLET_REPO] ❌ Cannot transfer to yourself');
        return false;
      }

      // ========== STEP 3: Update sender wallet (LOCAL + SERVER) ==========
      print('[WALLET_REPO] 📤 Updating sender wallet...');
      
      final senderBalanceBefore = senderWallet.balance;
      final senderBalanceAfter = senderBalanceBefore - amount;
      
      final updatedSenderWallet = senderWallet.copyWith(
        balance: senderBalanceAfter,
        totalSpent: senderWallet.totalSpent + amount,
        updatedAt: DateTime.now(),
      );

      // Update local
      await updateLocalWallet(updatedSenderWallet);
      
      // Update server
      await updateServerWallet(updatedSenderWallet);
      print('[WALLET_REPO] ✅ Sender wallet updated: ${senderBalanceBefore.toStringAsFixed(8)} → ${senderBalanceAfter.toStringAsFixed(8)}');

      // ========== STEP 4: Update recipient wallet (LOCAL + SERVER) ==========
      print('[WALLET_REPO] 📥 Updating recipient wallet...');
      
      final recipientBalanceBefore = recipientWallet.balance;
      final recipientBalanceAfter = recipientBalanceBefore + amount;
      
      final updatedRecipientWallet = recipientWallet.copyWith(
        balance: recipientBalanceAfter,
        totalEarned: recipientWallet.totalEarned + amount,
        updatedAt: DateTime.now(),
      );

      // Update server FIRST (quan trọng!)
      await updateServerWallet(updatedRecipientWallet);
      
      // Update local (hoặc sync from server)
      try {
        await updateLocalWallet(updatedRecipientWallet);
      } catch (e) {
        // Nếu recipient chưa có trong local, save mới
        await saveLocalWallet(updatedRecipientWallet);
      }
      
      print('[WALLET_REPO] ✅ Recipient wallet updated: ${recipientBalanceBefore.toStringAsFixed(8)} → ${recipientBalanceAfter.toStringAsFixed(8)}');

      // ========== STEP 5: Create transaction records ==========
      print('[WALLET_REPO] 📝 Creating transaction records...');
      
      final now = DateTime.now();
      final transactionId = _transactionRepo.generateTransactionId();

      // Transaction cho người GỬI
      final senderTransaction = TransactionModel(
        transactionId: '${transactionId}-send',
        userId: fromUserId,
        transactionType: 'transfer_send',
        amount: amount,
        netAmount: amount,
        balanceBefore: senderBalanceBefore,
        balanceAfter: senderBalanceAfter,
        fromUserId: fromUserId,
        toUserId: recipientWallet.userId,
        description: 'Transfer to ${toWalletAddress}',
        status: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      // Transaction cho người NHẬN
      final recipientTransaction = TransactionModel(
        transactionId: '${transactionId}-receive',
        userId: recipientWallet.userId,
        transactionType: 'transfer_receive',
        amount: amount,
        netAmount: amount,
        balanceBefore: recipientBalanceBefore,
        balanceAfter: recipientBalanceAfter,
        fromUserId: fromUserId,
        toUserId: recipientWallet.userId,
        description: 'Received from ${senderWallet.walletAddress}',
        status: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      // Save transactions
      await _transactionRepo.createTransaction(senderTransaction);
      await _transactionRepo.createTransaction(recipientTransaction);
      
      print('[WALLET_REPO] ✅ Transaction history created');

      // ========== DONE ==========
      print('[WALLET_REPO] 🎉 Internal transfer completed successfully!');
      print('[WALLET_REPO] Summary:');
      print('[WALLET_REPO]   - Sender: ${fromUserId}');
      print('[WALLET_REPO]   - Recipient: ${recipientWallet.userId}');
      print('[WALLET_REPO]   - Amount: $amount DFI');
      print('[WALLET_REPO]   - Sender new balance: $senderBalanceAfter');
      print('[WALLET_REPO]   - Recipient new balance: $recipientBalanceAfter');
      
      return true;
    } catch (e) {
      print('[WALLET_REPO] ❌ CRITICAL ERROR during internal transfer: $e');
      print('[WALLET_REPO] ⚠️ Transaction may be incomplete - please verify balances');
      return false;
    }
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Generate wallet address
  String _generateWalletAddress() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'DFI${timestamp}${(timestamp % 1000).toString().padLeft(3, '0')}';
  }
}

