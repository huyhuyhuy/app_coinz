import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isLoading => _isLoading;

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
      // TODO: Implement actual login API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // For demo purposes, accept any non-empty credentials
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userEmail = email;
        _userName = email.split('@').first;
        _userId = DateTime.now().millisecondsSinceEpoch.toString();

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'demo_token_${_userId}');
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_id', _userId!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
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
      // TODO: Implement actual registration API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // For demo purposes, accept any valid registration
      if (fullName.isNotEmpty && phoneNumber.isNotEmpty && email.isNotEmpty && password.isNotEmpty && password == confirmPassword) {
        _isAuthenticated = true;
        _userEmail = email;
        _userName = fullName;
        _userId = DateTime.now().millisecondsSinceEpoch.toString();

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'demo_token_${_userId}');
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', fullName);
        await prefs.setString('user_id', _userId!);
        await prefs.setString('user_full_name', fullName);
        await prefs.setString('user_phone', phoneNumber);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
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
