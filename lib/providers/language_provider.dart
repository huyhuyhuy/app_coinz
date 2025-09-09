import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    final countryCode = prefs.getString('country_code') ?? 'US';
    _currentLocale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode, String countryCode) async {
    _currentLocale = Locale(languageCode, countryCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    await prefs.setString('country_code', countryCode);
    
    notifyListeners();
  }

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'en') {
      changeLanguage('vi', 'VN');
    } else {
      changeLanguage('en', 'US');
    }
  }

  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
}
