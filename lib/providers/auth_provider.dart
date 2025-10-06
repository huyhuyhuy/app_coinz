import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';

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
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');

      if (token != null && email != null) {
        _isAuthenticated = true;
        _userEmail = email;
        _userName = name;
        _userId = prefs.getString('user_id');
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_id');

      // Reset state
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
