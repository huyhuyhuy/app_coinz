app open ad
ca-app-pub-4969810842586372/8233130697

banner ad:
ca-app-pub-4969810842586372/8184179176

ID app:
ca-app-pub-4969810842586372~7884796278

# App Coinz - Flutter Coin Mining App

A cross-platform Flutter application for coin mining and community features, supporting both Android and iOS platforms.

## 🚀 Features

### Phase 1 (Current) - Basic UI & Authentication
- ✅ **Splash Screen** - App introduction with animations
- ✅ **Authentication System** - Login/Register with local storage
- ✅ **Multi-language Support** - English and Vietnamese
- ✅ **Main Navigation** - Bottom navigation with 5 main tabs
- ✅ **Responsive Design** - Works on different screen sizes
- ✅ **Modern UI** - Material Design 3 with custom theming

## 🛠️ Technical Stack

- **Framework**: Flutter 3.35.1
- **Language**: Dart 3.9.0
- **State Management**: Provider
- **Local Storage**: SharedPreferences, Flutter Secure Storage
- **UI Components**: Material Design 3, Google Fonts
- **Localization**: Flutter Localizations
- **HTTP & WebSocket**: http, web_socket_channel
- **Image Handling**: image_picker
- **Ads Integration**: Google Mobile Ads

## 📱 Supported Platforms

- ✅ **Android** - API 30+ (Android 11+)
- ✅ **iOS** - iOS 12.0+
- ✅ **Web** - Chrome, Edge, Firefox
- ✅ **Windows** - Windows 10+
- ✅ **macOS** - macOS 10.15+
- ✅ **Linux** - Ubuntu 18.04+

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.1+
- Dart 3.9.0+
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd app_coinz
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/               # State management
│   ├── auth_provider.dart   # Authentication state
│   └── language_provider.dart # Language management
├── screens/                 # App screens
│   ├── splash_screen.dart   # Welcome screen
│   ├── login_screen.dart    # Login form
│   ├── register_screen.dart # Registration form
│   └── main_screen.dart     # Main app with tabs
├── widgets/                 # Reusable components
│   └── language_selector.dart # Language switcher
├── utils/                   # Utilities
│   └── app_localizations.dart # Localization strings
├── models/                  # Data models (planned)
├── services/                # API services (planned)
└── assets/                  # Images, icons, fonts
    ├── images/
    ├── icons/
    └── fonts/
```

## 🌐 Localization

The app supports multiple languages:
- **English (en-US)** - Default language
- **Vietnamese (vi-VN)** - Full translation support

Language can be changed via the language selector in the top-right corner of each screen.

## 🔐 Authentication

Current authentication system uses local storage for demo purposes:
- **Login**: Accepts any valid email/password combination
- **Register**: Creates new account with email/password
- **Session Management**: Automatically logs in returning users
- **Security**: Passwords stored securely using Flutter Secure Storage

## 🎨 UI/UX Features

- **Material Design 3**: Modern, adaptive design system
- **Responsive Layout**: Adapts to different screen sizes
- **Smooth Animations**: Fade and scale animations on splash screen
- **Custom Theming**: Primary color scheme with light/dark support
- **Accessibility**: Proper contrast ratios and touch targets

## 📊 Current Status

- **Phase 1**: ✅ **COMPLETED**
  - Basic app structure
  - Authentication system
  - Multi-language support
  - Navigation framework
  - UI components

- **Phase 2**: 🔄 **IN PROGRESS**
  - Mining functionality
  - Real-time updates
  - Statistics tracking

- **Phase 3**: 📋 **PLANNED**
  - Advanced features
  - Backend integration
  - Production deployment

## 🧪 Testing

### Manual Testing
- Test on different screen sizes
- Verify language switching
- Test authentication flow
- Check navigation between tabs

### Automated Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### build android debug test
```bash
flutter build apk --debug
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔮 Roadmap

### Short Term (1-2 months)
- Complete Phase 2 features
- Add real-time mining simulation
- Implement friend referral system

### Medium Term (3-6 months)
- Backend API development
- Database integration
- User management system

### Long Term (6+ months)
- Production deployment
- App store releases
- Community features
- Advanced security features

---
