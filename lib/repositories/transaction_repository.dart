import '../database/database_helper.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

/// Transaction Repository - Quản lý giao dịch
class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Create transaction (cả local và server)
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      print('[TRANSACTION_REPO] 💾 Creating transaction...');
      print('[TRANSACTION_REPO] Type: ${transaction.transactionType}');
      print('[TRANSACTION_REPO] Amount: ${transaction.amount}');
      print('[TRANSACTION_REPO] ID: ${transaction.transactionId}');

      // ✅ Check duplicate trước khi tạo
      final existingTransaction = await _dbHelper.queryOne(
        'transactions',
        where: 'transaction_id = ?',
        whereArgs: [transaction.transactionId],
      );

      if (existingTransaction != null) {
        print('[TRANSACTION_REPO] ⚠️ Transaction already exists: ${transaction.transactionId}');
        return true; // Return true vì transaction đã tồn tại
      }

      // 1. Save to server first
      try {
        await SupabaseService.client
            .from('transactions')
            .insert(transaction.toJson());
        print('[TRANSACTION_REPO] ✅ Transaction saved to server');
      } catch (e) {
        print('[TRANSACTION_REPO] ⚠️ Failed to save to server: $e');
        // Continue anyway, will sync later
      }

      // 2. Save to local database
      final transactionWithSync = transaction.copyWith(syncedToServer: true);
      await _dbHelper.insert('transactions', transactionWithSync.toMap());
      print('[TRANSACTION_REPO] ✅ Transaction saved to local database');

      return true;
    } catch (e) {
      print('[TRANSACTION_REPO] ❌ Error creating transaction: $e');
      return false;
    }
  }

  /// Get transactions for user (from local)
  Future<List<TransactionModel>> getUserTransactions(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return results.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      print('[TRANSACTION_REPO] ❌ Error getting transactions: $e');
      return [];
    }
  }

  /// Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(
    String userId,
    String type, {
    int limit = 50,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'transactions',
        where: 'user_id = ? AND transaction_type = ?',
        whereArgs: [userId, type],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return results.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      print('[TRANSACTION_REPO] ❌ Error getting transactions by type: $e');
      return [];
    }
  }

  /// Clean up old duplicate transactions (ONLY real duplicates - same timestamp to the minute)
  Future<void> cleanupDuplicateTransactions(String userId) async {
    try {
      print('[TRANSACTION_REPO] 🧹 Cleaning up duplicate transactions...');
      
      final allTransactions = await getUserTransactions(userId, limit: 1000);
      final Map<String, String> keepTransactionIds = {};
      final List<String> duplicateIds = [];
      
      for (final transaction in allTransactions) {
        // ✅ Create unique key: description + amount + timestamp (to the MINUTE)
        // This ensures we only delete REAL duplicates (same transaction at same time)
        final timestampToMinute = transaction.createdAt.toIso8601String().substring(0, 16); // YYYY-MM-DDTHH:MM
        final uniqueKey = '${transaction.transactionType}_${transaction.description}_${transaction.amount}_$timestampToMinute';
        
        if (!keepTransactionIds.containsKey(uniqueKey)) {
          // Keep this transaction
          keepTransactionIds[uniqueKey] = transaction.transactionId;
          print('[TRANSACTION_REPO] ✅ Keep: ${transaction.transactionId} - ${transaction.description} - $timestampToMinute');
        } else {
          // This is a real duplicate (same type, description, amount, and time to the minute)
          duplicateIds.add(transaction.transactionId);
          print('[TRANSACTION_REPO] ⚠️ Found duplicate: ${transaction.transactionId} - ${transaction.description} - $timestampToMinute');
        }
      }
      
      // Delete duplicate transactions
      for (final duplicateId in duplicateIds) {
        await _dbHelper.delete(
          'transactions',
          where: 'transaction_id = ?',
          whereArgs: [duplicateId],
        );
        print('[TRANSACTION_REPO] 🗑️ Deleted duplicate transaction: $duplicateId');
      }
      
      if (duplicateIds.isNotEmpty) {
        print('[TRANSACTION_REPO] ✅ Cleaned up ${duplicateIds.length} duplicate transactions');
      } else {
        print('[TRANSACTION_REPO] ✅ No duplicate transactions found');
      }
    } catch (e) {
      print('[TRANSACTION_REPO] ❌ Error cleaning up duplicates: $e');
    }
  }

  /// Sync transactions from server
  Future<bool> syncTransactionsFromServer(String userId) async {
    try {
      print('[TRANSACTION_REPO] 🔄 Syncing transactions from server...');

      // ✅ Tăng limit lên 500 để sync nhiều transactions hơn (bao gồm cả transactions cũ)
      final response = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(500);

      final serverTransactions = (response as List)
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('[TRANSACTION_REPO] 📥 Got ${serverTransactions.length} transactions from server');

      // Save to local database
      for (var transaction in serverTransactions) {
        try {
          // ✅ Check duplicate trước khi insert/update
          final existingTransaction = await _dbHelper.queryOne(
            'transactions',
            where: 'transaction_id = ?',
            whereArgs: [transaction.transactionId],
          );

          if (existingTransaction == null) {
            // Transaction chưa tồn tại, insert mới
            await _dbHelper.insert('transactions', transaction.toMap());
            print('[TRANSACTION_REPO] ✅ New transaction synced: ${transaction.transactionId}');
          } else {
            // Transaction đã tồn tại, update nếu cần
            await _dbHelper.update(
              'transactions',
              transaction.toMap(),
              where: 'transaction_id = ?',
              whereArgs: [transaction.transactionId],
            );
            print('[TRANSACTION_REPO] ✅ Existing transaction updated: ${transaction.transactionId}');
          }
        } catch (e) {
          print('[TRANSACTION_REPO] ❌ Error syncing transaction ${transaction.transactionId}: $e');
        }
      }

      print('[TRANSACTION_REPO] ✅ Transactions synced from server');
      return true;
    } catch (e) {
      print('[TRANSACTION_REPO] ❌ Error syncing transactions: $e');
      return false;
    }
  }

  /// Generate transaction ID
  String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final microseconds = DateTime.now().microsecondsSinceEpoch;
    
    // Generate UUID v4 format
    final part1 = timestamp.toRadixString(16).padLeft(8, '0').substring(0, 8);
    final part2 = (timestamp % 65536).toRadixString(16).padLeft(4, '0');
    final part3 = '4${(microseconds % 4096).toRadixString(16).padLeft(3, '0')}';
    final part4 = 'a${(microseconds % 4096).toRadixString(16).padLeft(3, '0')}';
    final part5 = microseconds.toRadixString(16).padLeft(12, '0').substring(0, 12);

    return '$part1-$part2-$part3-$part4-$part5';
  }
}

