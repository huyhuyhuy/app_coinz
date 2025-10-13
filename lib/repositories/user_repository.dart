import '../database/database_helper.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

/// User Repository - Quản lý dữ liệu user (local + server)
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // ============================================================================
  // LOCAL DATABASE OPERATIONS
  // ============================================================================
  
  /// Get user from local database by userId
  Future<UserModel?> getLocalUser(String userId) async {
    try {
      final result = await _dbHelper.queryOne(
        'users',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (result == null) return null;
      return UserModel.fromMap(result);
    } catch (e) {
      print('[USER_REPO] ❌ Error getting local user: $e');
      return null;
    }
  }
  
  /// Get user from local database by email
  Future<UserModel?> getLocalUserByEmail(String email) async {
    try {
      final result = await _dbHelper.queryOne(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (result == null) return null;
      return UserModel.fromMap(result);
    } catch (e) {
      print('[USER_REPO] ❌ Error getting local user by email: $e');
      return null;
    }
  }
  
  /// Save user to local database
  Future<bool> saveLocalUser(UserModel user) async {
    try {
      await _dbHelper.insert('users', user.toMap());
      print('[USER_REPO] ✅ User saved to local database: ${user.email}');
      return true;
    } catch (e) {
      print('[USER_REPO] ❌ Error saving local user: $e');
      return false;
    }
  }
  
  /// Update user in local database
  Future<bool> updateLocalUser(UserModel user) async {
    try {
      await _dbHelper.update(
        'users',
        user.toMap(),
        where: 'user_id = ?',
        whereArgs: [user.userId],
      );
      print('[USER_REPO] ✅ User updated in local database: ${user.email}');
      return true;
    } catch (e) {
      print('[USER_REPO] ❌ Error updating local user: $e');
      return false;
    }
  }
  
  // ============================================================================
  // SERVER DATABASE OPERATIONS
  // ============================================================================
  
  /// Get user from server by userId
  Future<UserModel?> getServerUser(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      print('[USER_REPO] ✅ User fetched from server: ${response['email']}');
      return UserModel.fromJson(response);
    } catch (e) {
      print('[USER_REPO] ❌ Error getting server user: $e');
      return null;
    }
  }
  
  /// Get user from server by email
  Future<UserModel?> getServerUserByEmail(String email) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('email', email)
          .single();
      
      print('[USER_REPO] ✅ User fetched from server: ${response['email']}');
      return UserModel.fromJson(response);
    } catch (e) {
      print('[USER_REPO] ❌ Error getting server user by email: $e');
      return null;
    }
  }
  
  /// Create user on server
  Future<UserModel?> createServerUser(UserModel user) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      
      print('[USER_REPO] ✅ User created on server: ${response['email']}');
      return UserModel.fromJson(response);
    } catch (e) {
      print('[USER_REPO] ❌ Error creating server user: $e');
      return null;
    }
  }
  
  /// Update user on server
  Future<bool> updateServerUser(UserModel user) async {
    try {
      await SupabaseService.client
          .from('users')
          .update(user.toJson())
          .eq('id', user.userId);
      
      print('[USER_REPO] ✅ User updated on server: ${user.email}');
      return true;
    } catch (e) {
      print('[USER_REPO] ❌ Error updating server user: $e');
      return false;
    }
  }
  
  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================
  
  /// Sync user from server to local
  Future<bool> syncUserFromServer(String userId) async {
    try {
      print('[USER_REPO] 🔄 Syncing user from server...');
      
      final serverUser = await getServerUser(userId);
      if (serverUser == null) {
        print('[USER_REPO] ❌ User not found on server');
        return false;
      }
      
      final localUser = await getLocalUser(userId);
      if (localUser == null) {
        await saveLocalUser(serverUser);
      } else {
        await updateLocalUser(serverUser);
      }
      
      print('[USER_REPO] ✅ User synced from server');
      return true;
    } catch (e) {
      print('[USER_REPO] ❌ Error syncing user from server: $e');
      return false;
    }
  }
  
  /// Sync user from local to server
  Future<bool> syncUserToServer(String userId) async {
    try {
      print('[USER_REPO] 🔄 Syncing user to server...');
      
      final localUser = await getLocalUser(userId);
      if (localUser == null) {
        print('[USER_REPO] ❌ User not found in local database');
        return false;
      }
      
      final serverUser = await getServerUser(userId);
      if (serverUser == null) {
        await createServerUser(localUser);
      } else {
        await updateServerUser(localUser);
      }
      
      print('[USER_REPO] ✅ User synced to server');
      return true;
    } catch (e) {
      print('[USER_REPO] ❌ Error syncing user to server: $e');
      return false;
    }
  }
  
  // ============================================================================
  // AUTHENTICATION OPERATIONS
  // ============================================================================
  
  /// Register new user
  Future<UserModel?> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? referralCode,
  }) async {
    try {
      print('[USER_REPO] 📝 Registering new user: $email');
      
      // Check if user already exists
      final existingUser = await getServerUserByEmail(email);
      if (existingUser != null) {
        print('[USER_REPO] ❌ User already exists');
        return null;
      }

      // Validate referral code if provided
      UserModel? referrer;
      if (referralCode != null && referralCode.isNotEmpty) {
        print('[USER_REPO] 🔍 Validating referral code: $referralCode');
        
        // Tìm người giới thiệu bằng referral code
        try {
          final response = await SupabaseService.client
              .from('users')
              .select()
              .eq('referral_code', referralCode)
              .single();
          
          referrer = UserModel.fromJson(response);
          print('[USER_REPO] ✅ Referral code valid. Referrer: ${referrer.fullName}');
        } catch (e) {
          print('[USER_REPO] ❌ Invalid referral code: $referralCode');
          // Mã không hợp lệ - không throw error, chỉ bỏ qua
          referrer = null;
        }
      }
      
      // Create user model with UUID format
      final user = UserModel(
        userId: _generateUuid(),
        email: email,
        passwordHash: password, // TODO: Hash password with bcrypt
        fullName: fullName,
        phoneNumber: phoneNumber,
        referralCode: _generateReferralCode(),
        referredBy: referrer?.userId, // Lưu ID người giới thiệu
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to server
      final serverUser = await createServerUser(user);
      if (serverUser == null) {
        print('[USER_REPO] ❌ Failed to create user on server');
        return null;
      }
      
      // Save to local
      await saveLocalUser(serverUser);

      // Nếu có người giới thiệu, tăng totalReferrals cho họ
      if (referrer != null) {
        print('[USER_REPO] 🎁 Incrementing referrals for: ${referrer.fullName}');
        
        try {
          final updatedReferrer = referrer.copyWith(
            totalReferrals: referrer.totalReferrals + 1,
            updatedAt: DateTime.now(),
          );
          
          await updateServerUser(updatedReferrer);
          await updateLocalUser(updatedReferrer);
          
          print('[USER_REPO] ✅ Referrer totalReferrals: ${referrer.totalReferrals} → ${updatedReferrer.totalReferrals}');
        } catch (e) {
          print('[USER_REPO] ⚠️ Failed to update referrer: $e');
          // Không throw error, user registration đã thành công
        }
      }
      
      print('[USER_REPO] ✅ User registered successfully');
      return serverUser;
    } catch (e) {
      print('[USER_REPO] ❌ Error registering user: $e');
      return null;
    }
  }
  
  /// Login user
  Future<UserModel?> login(String email, String password) async {
    try {
      print('[USER_REPO] 🔐 Logging in user: $email');
      
      // Get user from server
      final user = await getServerUserByEmail(email);
      if (user == null) {
        print('[USER_REPO] ❌ User not found');
        return null;
      }
      
      // Check password (TODO: Use bcrypt)
      if (user.passwordHash != password) {
        print('[USER_REPO] ❌ Invalid password');
        return null;
      }
      
      // Update last login
      final updatedUser = user.copyWith(lastLogin: DateTime.now());
      await updateServerUser(updatedUser);
      
      // Save to local
      await saveLocalUser(updatedUser);
      
      print('[USER_REPO] ✅ User logged in successfully');
      return updatedUser;
    } catch (e) {
      print('[USER_REPO] ❌ Error logging in: $e');
      return null;
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

  /// Generate referral code
  String _generateReferralCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'REF${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }
}

