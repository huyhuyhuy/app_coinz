import '../database/database_helper.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import 'wallet_repository.dart';

/// Mining Repository - Quản lý mining sessions (local + server)
class MiningRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final WalletRepository _walletRepo = WalletRepository();
  
  // ============================================================================
  // LOCAL DATABASE OPERATIONS
  // ============================================================================
  
  /// Get active mining session
  Future<MiningSessionModel?> getActiveMiningSession(String userId) async {
    try {
      final results = await _dbHelper.query(
        'mining_sessions',
        where: 'user_id = ? AND is_active = ?',
        whereArgs: [userId, 1],
        orderBy: 'start_time DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;
      return MiningSessionModel.fromMap(results.first);
    } catch (e) {
      print('[MINING_REPO] ❌ Error getting active mining session: $e');
      return null;
    }
  }
  
  /// Get all mining sessions for user
  Future<List<MiningSessionModel>> getMiningSessionsForUser(String userId) async {
    try {
      final results = await _dbHelper.query(
        'mining_sessions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'start_time DESC',
      );
      
      return results.map((r) => MiningSessionModel.fromMap(r)).toList();
    } catch (e) {
      print('[MINING_REPO] ❌ Error getting mining sessions: $e');
      return [];
    }
  }
  
  /// Save mining session to local database
  Future<bool> saveLocalMiningSession(MiningSessionModel session) async {
    try {
      await _dbHelper.insert('mining_sessions', session.toMap());
      print('[MINING_REPO] ✅ Mining session saved to local database');
      return true;
    } catch (e) {
      print('[MINING_REPO] ❌ Error saving local mining session: $e');
      return false;
    }
  }
  
  /// Update mining session in local database
  Future<bool> updateLocalMiningSession(MiningSessionModel session) async {
    try {
      await _dbHelper.update(
        'mining_sessions',
        session.toMap(),
        where: 'session_id = ?',
        whereArgs: [session.sessionId],
      );
      print('[MINING_REPO] ✅ Mining session updated in local database');
      return true;
    } catch (e) {
      print('[MINING_REPO] ❌ Error updating local mining session: $e');
      return false;
    }
  }
  
  // ============================================================================
  // SERVER DATABASE OPERATIONS
  // ============================================================================
  
  /// Create mining session on server
  Future<MiningSessionModel?> createServerMiningSession(MiningSessionModel session) async {
    try {
      final response = await SupabaseService.client
          .from('mining_sessions')
          .insert(session.toJson())
          .select()
          .single();
      
      print('[MINING_REPO] ✅ Mining session created on server');
      return MiningSessionModel.fromJson(response);
    } catch (e) {
      print('[MINING_REPO] ❌ Error creating server mining session: $e');
      return null;
    }
  }
  
  /// Update mining session on server
  Future<bool> updateServerMiningSession(MiningSessionModel session) async {
    try {
      await SupabaseService.client
          .from('mining_sessions')
          .update(session.toJson())
          .eq('id', session.sessionId);
      
      print('[MINING_REPO] ✅ Mining session updated on server');
      return true;
    } catch (e) {
      print('[MINING_REPO] ❌ Error updating server mining session: $e');
      return false;
    }
  }
  
  // ============================================================================
  // MINING OPERATIONS
  // ============================================================================
  
  /// Start mining session
  Future<MiningSessionModel?> startMining(String userId, {double speedMultiplier = 1.0}) async {
    try {
      print('[MINING_REPO] ⛏️ Starting mining session for user: $userId');
      
      // Check if there's already an active session
      final activeSession = await getActiveMiningSession(userId);
      if (activeSession != null) {
        print('[MINING_REPO] ⚠️ Mining session already active');
        return activeSession;
      }
      
      // Create new mining session
      final session = MiningSessionModel(
        sessionId: _generateUuid(),
        userId: userId,
        startTime: DateTime.now(),
        baseMiningSpeed: 0.001, // 0.001 coins per second
        actualMiningSpeed: 0.001 * speedMultiplier,
        speedMultiplier: speedMultiplier,
        createdAt: DateTime.now(),
      );
      
      // Save to local
      await saveLocalMiningSession(session);
      
      // Save to server (async, don't wait)
      createServerMiningSession(session).catchError((e) {
        print('[MINING_REPO] ⚠️ Failed to sync mining session to server: $e');
      });
      
      print('[MINING_REPO] ✅ Mining session started');
      return session;
    } catch (e) {
      print('[MINING_REPO] ❌ Error starting mining: $e');
      return null;
    }
  }
  
  /// Stop mining session
  Future<MiningSessionModel?> stopMining(String userId) async {
    try {
      print('[MINING_REPO] 🛑 Stopping mining session for user: $userId');
      
      // Get active session
      final activeSession = await getActiveMiningSession(userId);
      if (activeSession == null) {
        print('[MINING_REPO] ⚠️ No active mining session');
        return null;
      }
      
      // Calculate final values
      final now = DateTime.now();
      final duration = now.difference(activeSession.startTime).inSeconds;
      final coinsMined = activeSession.actualMiningSpeed * duration;
      
      // Update session
      final updatedSession = activeSession.copyWith(
        endTime: now,
        durationSeconds: duration,
        coinsMined: coinsMined,
        isActive: false,
      );
      
      // Update local
      await updateLocalMiningSession(updatedSession);
      
      // Add coins to wallet
      await _walletRepo.addCoins(userId, coinsMined);
      
      // Update server (async, don't wait)
      updateServerMiningSession(updatedSession).catchError((e) {
        print('[MINING_REPO] ⚠️ Failed to sync mining session to server: $e');
      });
      
      print('[MINING_REPO] ✅ Mining session stopped. Coins mined: $coinsMined');
      return updatedSession;
    } catch (e) {
      print('[MINING_REPO] ❌ Error stopping mining: $e');
      return null;
    }
  }
  
  /// Get current mining progress
  Future<Map<String, dynamic>?> getMiningProgress(String userId) async {
    try {
      final activeSession = await getActiveMiningSession(userId);
      if (activeSession == null) {
        return null;
      }
      
      final now = DateTime.now();
      final duration = now.difference(activeSession.startTime).inSeconds;
      final coinsMined = activeSession.actualMiningSpeed * duration;
      
      return {
        'session': activeSession,
        'duration': duration,
        'coinsMined': coinsMined,
        'miningSpeed': activeSession.actualMiningSpeed,
        'isActive': true,
      };
    } catch (e) {
      print('[MINING_REPO] ❌ Error getting mining progress: $e');
      return null;
    }
  }
  
  /// Get total coins mined by user
  Future<double> getTotalCoinsMined(String userId) async {
    try {
      final sessions = await getMiningSessionsForUser(userId);
      double total = 0;
      for (var session in sessions) {
        total += session.coinsMined;
      }
      return total;
    } catch (e) {
      print('[MINING_REPO] ❌ Error getting total coins mined: $e');
      return 0;
    }
  }
  
  /// Get total mining time by user
  Future<int> getTotalMiningTime(String userId) async {
    try {
      final sessions = await getMiningSessionsForUser(userId);
      int total = 0;
      for (var session in sessions) {
        total += session.durationSeconds;
      }
      return total;
    } catch (e) {
      print('[MINING_REPO] ❌ Error getting total mining time: $e');
      return 0;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Generate UUID v4 format (without external package)
  String _generateUuid() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final microseconds = DateTime.now().microsecondsSinceEpoch;

    // Generate UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final part1 = timestamp.toRadixString(16).padLeft(8, '0').substring(0, 8);
    final part2 = (timestamp % 65536).toRadixString(16).padLeft(4, '0');
    final part3 = '4${(microseconds % 4096).toRadixString(16).padLeft(3, '0')}';
    final part4 = 'a${(microseconds % 4096).toRadixString(16).padLeft(3, '0')}';
    final part5 = microseconds.toRadixString(16).padLeft(12, '0').substring(0, 12);

    return '$part1-$part2-$part3-$part4-$part5';
  }
}

