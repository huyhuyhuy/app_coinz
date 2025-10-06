import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();
  final WalletRepository _walletRepo = WalletRepository();

  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String? _userPhone;
  bool _isLoading = false;
  UserModel? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('[AUTH_PROVIDER] 🔍 Checking auth status...');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      final userId = prefs.getString('user_id');
      final phone = prefs.getString('user_phone');

      print('[AUTH_PROVIDER] 📋 Stored data: token=$token, email=$email, userId=$userId');

      if (token != null && email != null && userId != null) {
        print('[AUTH_PROVIDER] 🔄 Restoring session: $email');
        _isAuthenticated = true;
        _userEmail = email;
        _userName = name;
        _userId = userId;
        _userPhone = phone;

        // Sync wallet from server
        try {
          await _walletRepo.syncWalletFromServer(userId);
          print('[AUTH_PROVIDER] ✅ Session restored successfully');
        } catch (e) {
          print('[AUTH_PROVIDER] ⚠️ Failed to sync wallet: $e');
        }
      } else {
        print('[AUTH_PROVIDER] ℹ️ No session found');
        _isAuthenticated = false;
      }
    } catch (e) {
      print('[AUTH_PROVIDER] ❌ Failed to restore session: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('[AUTH_PROVIDER] ✅ Auth check completed. isAuthenticated=$_isAuthenticated');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('[AUTH_PROVIDER] 🔐 Logging in: $email');

      // Login with UserRepository
      final user = await _userRepo.login(email, password);

      if (user != null) {
        _isAuthenticated = true;
        _currentUser = user;
        _userId = user.userId;
        _userEmail = user.email;
        _userName = user.fullName;
        _userPhone = user.phoneNumber;

        // Sync wallet from server to local
        await _walletRepo.syncWalletFromServer(user.userId);

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'token_${user.userId}');
        await prefs.setString('user_id', user.userId);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_name', user.fullName);
        if (user.phoneNumber != null) {
          await prefs.setString('user_phone', user.phoneNumber!);
        }

        print('[AUTH_PROVIDER] ✅ Login successful');
        notifyListeners();
        return true;
      }

      print('[AUTH_PROVIDER] ❌ Login failed');
      return false;
    } catch (e) {
      print('[AUTH_PROVIDER] ❌ Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String fullName, String phoneNumber, String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('[AUTH_PROVIDER] 📝 Registering: $email');

      // Validate
      if (password != confirmPassword) {
        print('[AUTH_PROVIDER] ❌ Passwords do not match');
        return false;
      }

      // Register with UserRepository
      final user = await _userRepo.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      if (user != null) {
        _isAuthenticated = true;
        _currentUser = user;
        _userId = user.userId;
        _userEmail = user.email;
        _userName = user.fullName;
        _userPhone = user.phoneNumber;

        // Create wallet for new user
        await _walletRepo.createWallet(user.userId);

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'token_${user.userId}');
        await prefs.setString('user_id', user.userId);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_name', user.fullName);
        if (user.phoneNumber != null) {
          await prefs.setString('user_phone', user.phoneNumber!);
        }

        print('[AUTH_PROVIDER] ✅ Registration successful');
        notifyListeners();
        return true;
      }

      print('[AUTH_PROVIDER] ❌ Registration failed');
      return false;
    } catch (e) {
      print('[AUTH_PROVIDER] ❌ Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('[AUTH_PROVIDER] 🚪 Logging out...');

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_id');
      await prefs.remove('user_phone');
      print('[AUTH_PROVIDER] ✅ SharedPreferences cleared');

      // Clear local database
      try {
        final db = await DatabaseHelper.instance.database;

        // Xóa tất cả data trong các bảng
        await db.delete('users');
        await db.delete('wallets');
        await db.delete('mining_sessions');
        await db.delete('mining_stats');
        await db.delete('transactions');
        await db.delete('notifications');
        await db.delete('friends');
        await db.delete('news_cache');
        await db.delete('settings');

        print('[AUTH_PROVIDER] ✅ Local database cleared');
      } catch (e) {
        print('[AUTH_PROVIDER] ⚠️ Failed to clear database: $e');
      }

      // Reset state
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _userPhone = null;
      _currentUser = null;

      print('[AUTH_PROVIDER] ✅ Logout successful');
    } catch (e) {
      print('[AUTH_PROVIDER] ❌ Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
