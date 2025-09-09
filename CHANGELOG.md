# Changelog - App Coinz

## [1.1.0] - 2025-08-24

### ✨ Added
- **Enhanced Registration Form**: Added new fields for better user identification
  - **Full Name Field**: Họ và tên (must match CCCD/ID card)
  - **Phone Number Field**: Số điện thoại with validation
- **Improved Validation**: 
  - Full name must contain at least first and last name
  - Phone number must be at least 10 digits
  - Vietnamese language validation messages
- **Enhanced User Profile**: 
  - Display full name instead of email username
  - Show phone number in profile tab
  - Better user information storage

### 🔧 Changed
- **AuthProvider**: Updated registration method to handle new fields
- **Local Storage**: Enhanced to store full name and phone number
- **Localization**: Added new strings for full name and phone number
- **Form Validation**: Improved validation logic for new fields

### 🌐 Localization Updates
- Added `fullName` string (English: "Full Name", Vietnamese: "Họ và tên")
- Added `phoneNumber` string (English: "Phone Number", Vietnamese: "Số điện thoại")
- Enhanced validation messages in Vietnamese

### 📱 UI/UX Improvements
- Better form layout with logical field ordering
- Improved validation feedback
- Enhanced profile display with phone number
- Consistent styling across all form fields

### 🔒 Security & Compliance
- **KYC Preparation**: New fields align with identity verification requirements
- **Data Validation**: Ensures data quality for future KYC processes
- **User Identification**: Better user tracking and verification

---

## [1.0.0] - 2025-08-24

### 🎉 Initial Release
- **Complete Flutter App Structure**: Cross-platform coin mining application
- **Authentication System**: Login/Register with local storage
- **Multi-language Support**: English and Vietnamese
- **Modern UI**: Material Design 3 with responsive design
- **Navigation Framework**: 5 main tabs (Home, Mining, Wallet, Friends, Profile)
- **State Management**: Provider pattern implementation
- **Localization System**: Complete Vietnamese and English support

### 🚀 Features
- Splash screen with animations
- Authentication flow (login/register)
- Language switching (EN/VI)
- Bottom navigation
- Responsive design for all screen sizes
- Modern Material Design 3 theming

### 🛠️ Technical Stack
- Flutter 3.35.1
- Dart 3.9.0
- Provider for state management
- SharedPreferences for local storage
- Google Fonts for typography
- Flutter Localizations for multi-language support

---

## Roadmap

### Phase 2 (Next)
- Real-time mining functionality
- Mining statistics and tracking
- Google AdMob integration
- Friend referral system

### Phase 3 (Future)
- Wallet integration
- Community features
- KYC system implementation
- Transaction system
- Backend API integration
