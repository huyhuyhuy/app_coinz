import 'package:flutter/material.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';

/// Wallet Provider - Quản lý ví coin
class WalletProvider with ChangeNotifier {
  final WalletRepository _walletRepo = WalletRepository();
  
  // Wallet state
  WalletModel? _wallet;
  bool _isLoading = false;
  
  // Getters
  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  double get balance => _wallet?.balance ?? 0.0;
  double get totalEarned => _wallet?.totalEarned ?? 0.0;
  double get totalSpent => _wallet?.totalSpent ?? 0.0;
  double get totalWithdrawn => _wallet?.totalWithdrawn ?? 0.0;
  String get walletAddress => _wallet?.walletAddress ?? '';
  
  // Formatted getters
  String get formattedBalance => balance.toStringAsFixed(8);
  String get formattedBalanceShort => balance.toStringAsFixed(2);
  String get shortWalletAddress {
    if (walletAddress.length <= 10) return walletAddress;
    return '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}';
  }
  
  /// Initialize wallet provider
  Future<void> initialize(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      print('[WALLET_PROVIDER] 🚀 Initializing wallet provider...');
      
      // Try to get wallet from local database
      _wallet = await _walletRepo.getLocalWallet(userId);

      if (_wallet == null) {
        print('[WALLET_PROVIDER] ℹ️ Wallet not found locally, checking server...');

        // Try to get from server
        _wallet = await _walletRepo.getServerWallet(userId);

        if (_wallet == null) {
          print('[WALLET_PROVIDER] ℹ️ Wallet not found on server, creating new wallet...');

          // Create new wallet
          _wallet = await _walletRepo.createWallet(userId);
        } else {
          // Save to local
          await _walletRepo.saveLocalWallet(_wallet!);
        }
      } else {
        // Wallet exists locally, sync from server to get latest balance
        print('[WALLET_PROVIDER] 🔄 Syncing wallet from server...');
        await _walletRepo.syncWalletFromServer(userId);
        _wallet = await _walletRepo.getLocalWallet(userId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      if (_wallet != null) {
        print('[WALLET_PROVIDER] ✅ Wallet initialized: ${_wallet!.walletAddress}');
      } else {
        print('[WALLET_PROVIDER] ❌ Failed to initialize wallet');
      }
    } catch (e) {
      print('[WALLET_PROVIDER] ❌ Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Refresh wallet data
  Future<void> refresh(String userId) async {
    try {
      print('[WALLET_PROVIDER] 🔄 Refreshing wallet...');
      
      // Get latest wallet data from local
      _wallet = await _walletRepo.getLocalWallet(userId);
      
      notifyListeners();
      print('[WALLET_PROVIDER] ✅ Wallet refreshed');
    } catch (e) {
      print('[WALLET_PROVIDER] ❌ Error refreshing wallet: $e');
    }
  }
  
  /// Sync wallet with server
  Future<bool> syncWithServer(String userId) async {
    try {
      print('[WALLET_PROVIDER] 🔄 Syncing wallet with server...');
      
      final success = await _walletRepo.syncWalletToServer(userId);
      
      if (success) {
        print('[WALLET_PROVIDER] ✅ Wallet synced with server');
      } else {
        print('[WALLET_PROVIDER] ❌ Failed to sync wallet with server');
      }
      
      return success;
    } catch (e) {
      print('[WALLET_PROVIDER] ❌ Error syncing wallet: $e');
      return false;
    }
  }
  
  /// Add coins to wallet (called by mining provider)
  Future<bool> addCoins(String userId, double amount) async {
    try {
      print('[WALLET_PROVIDER] 💰 Adding $amount coins to wallet...');
      
      final success = await _walletRepo.addCoins(userId, amount);
      
      if (success) {
        await refresh(userId);
        print('[WALLET_PROVIDER] ✅ Coins added successfully');
      } else {
        print('[WALLET_PROVIDER] ❌ Failed to add coins');
      }
      
      return success;
    } catch (e) {
      print('[WALLET_PROVIDER] ❌ Error adding coins: $e');
      return false;
    }
  }
  
  /// Subtract coins from wallet (for withdrawal/transfer)
  Future<bool> subtractCoins(String userId, double amount) async {
    try {
      print('[WALLET_PROVIDER] 💸 Subtracting $amount coins from wallet...');
      
      if (balance < amount) {
        print('[WALLET_PROVIDER] ❌ Insufficient balance');
        return false;
      }
      
      final success = await _walletRepo.subtractCoins(userId, amount);
      
      if (success) {
        await refresh(userId);
        print('[WALLET_PROVIDER] ✅ Coins subtracted successfully');
      } else {
        print('[WALLET_PROVIDER] ❌ Failed to subtract coins');
      }
      
      return success;
    } catch (e) {
      print('[WALLET_PROVIDER] ❌ Error subtracting coins: $e');
      return false;
    }
  }

  /// Transfer coins to another user (internal transfer)
  Future<bool> transferInternal({
    required String fromUserId,
    required String toWalletAddress,
    required double amount,
  }) async {
    try {
      print('[WALLET_PROVIDER] 💸 Transferring $amount coins...');
      
      if (balance < amount) {
        print('[WALLET_PROVIDER] ❌ Insufficient balance');
        return false;
      }

      final success = await _walletRepo.transferInternal(
        fromUserId: fromUserId,
        toWalletAddress: toWalletAddress,
        amount: amount,
      );

      if (success) {
        await refresh(fromUserId);
        print('[WALLET_PROVIDER] ✅ Transfer completed successfully');
      } else {
        print('[WALLET_PROVIDER] ❌ Transfer failed');
      }

      return success;
    } catch (e) {
      print('[WALLET_PROVIDER] ❌ Error transferring coins: $e');
      return false;
    }
  }
}

