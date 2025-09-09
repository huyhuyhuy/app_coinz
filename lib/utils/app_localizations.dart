import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('vi', 'VN'),
  ];

  // App Title
  String get appTitle {
    switch (locale.languageCode) {
      case 'vi':
        return 'App Coinz';
      default:
        return 'App Coinz';
    }
  }

  // Authentication
  String get login {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đăng nhập';
      default:
        return 'Login';
    }
  }

  String get register {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đăng ký';
      default:
        return 'Register';
    }
  }

  String get email {
    switch (locale.languageCode) {
      case 'vi':
        return 'Email';
      default:
        return 'Email';
    }
  }

  String get fullName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Họ và tên';
      default:
        return 'Full Name';
    }
  }

  String get phoneNumber {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số điện thoại';
      default:
        return 'Phone Number';
    }
  }

  String get password {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mật khẩu';
      default:
        return 'Password';
    }
  }

  String get confirmPassword {
    switch (locale.languageCode) {
      case 'vi':
        return 'Xác nhận mật khẩu';
      default:
        return 'Confirm Password';
    }
  }

  String get forgotPassword {
    switch (locale.languageCode) {
      case 'vi':
        return 'Quên mật khẩu?';
      default:
        return 'Forgot Password?';
    }
  }

  // Main Menu
  String get home {
    switch (locale.languageCode) {
      case 'vi':
        return 'Trang chủ';
      default:
        return 'Home';
    }
  }

  String get mining {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đào coin';
      default:
        return 'Mining';
    }
  }

  String get wallet {
    switch (locale.languageCode) {
      case 'vi':
        return 'Ví';
      default:
        return 'Wallet';
    }
  }

  String get friends {
    switch (locale.languageCode) {
      case 'vi':
        return 'Bạn bè';
      default:
        return 'Friends';
    }
  }

  String get news {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tin tức';
      default:
        return 'News';
    }
  }

  String get profile {
    switch (locale.languageCode) {
      case 'vi':
        return 'Hồ sơ';
      default:
        return 'Profile';
    }
  }

  // Mining Stats
  String get coinsMined {
    switch (locale.languageCode) {
      case 'vi':
        return 'Coin đã đào';
      default:
        return 'Coins Mined';
    }
  }

  String get miningSpeed {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tốc độ đào';
      default:
        return 'Mining Speed';
    }
  }

  String get onlineTime {
    switch (locale.languageCode) {
      case 'vi':
        return 'Thời gian online';
      default:
        return 'Online Time';
    }
  }

  // Actions
  String get share {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chia sẻ';
      default:
        return 'Share';
    }
  }

  String get settings {
    switch (locale.languageCode) {
      case 'vi':
        return 'Cài đặt';
      default:
        return 'Settings';
    }
  }

  String get logout {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đăng xuất';
      default:
        return 'Logout';
    }
  }

  // Messages
  String get welcomeMessage {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chào mừng đến với App Coinz!';
      default:
        return 'Welcome to App Coinz!';
    }
  }

  String get startMining {
    switch (locale.languageCode) {
      case 'vi':
        return 'Bắt đầu đào coin';
      default:
        return 'Start Mining';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
