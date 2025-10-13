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
        return 'Nhiệm vụ';
      default:
        return 'Task';
    }
  }

  String get task {
    switch (locale.languageCode) {
      case 'vi':
        return 'Nhiệm vụ';
      default:
        return 'Task';
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

  String get stopMining {
    switch (locale.languageCode) {
      case 'vi':
        return 'Dừng đào';
      default:
        return 'Stop Mining';
    }
  }

  String get totalBalance {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tổng số dư';
      default:
        return 'Total Balance';
    }
  }

  String get withdraw {
    switch (locale.languageCode) {
      case 'vi':
        return 'Rút tiền';
      default:
        return 'Withdraw';
    }
  }

  String get comingSoon {
    switch (locale.languageCode) {
      case 'vi':
        return 'Sắp ra mắt';
      default:
        return 'Coming Soon';
    }
  }

  String get miningHistory {
    switch (locale.languageCode) {
      case 'vi':
        return 'Lịch sử đào';
      default:
        return 'Mining History';
    }
  }

  String get withdrawalHistory {
    switch (locale.languageCode) {
      case 'vi':
        return 'Lịch sử rút tiền';
      default:
        return 'Withdrawal History';
    }
  }

  String get noTransactions {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chưa có giao dịch';
      default:
        return 'No transactions yet';
    }
  }

  String get totalCoinsMined {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tổng coin đã đào';
      default:
        return 'Total Coins Mined';
    }
  }

  String get totalMiningTime {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tổng thời gian đào';
      default:
        return 'Total Mining Time';
    }
  }

  String get totalSessions {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tổng số phiên';
      default:
        return 'Total Sessions';
    }
  }

  String get createAccount {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tạo tài khoản';
      default:
        return 'Create Account';
    }
  }

  String get alreadyHaveAccount {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đã có tài khoản?';
      default:
        return 'Already have an account?';
    }
  }

  String get dontHaveAccount {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chưa có tài khoản?';
      default:
        return "Don't have an account?";
    }
  }

  String get pleaseEnterEmail {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập email';
      default:
        return 'Please enter your email';
    }
  }

  String get pleaseEnterValidEmail {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập email hợp lệ';
      default:
        return 'Please enter a valid email';
    }
  }

  String get pleaseEnterPassword {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập mật khẩu';
      default:
        return 'Please enter your password';
    }
  }

  String get passwordTooShort {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mật khẩu phải có ít nhất 6 ký tự';
      default:
        return 'Password must be at least 6 characters';
    }
  }

  String get pleaseConfirmPassword {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng xác nhận mật khẩu';
      default:
        return 'Please confirm your password';
    }
  }

  String get passwordsDoNotMatch {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mật khẩu không khớp';
      default:
        return 'Passwords do not match';
    }
  }

  String get pleaseEnterFullName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập họ và tên';
      default:
        return 'Please enter your full name';
    }
  }

  String get pleaseEnterPhoneNumber {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập số điện thoại';
      default:
        return 'Please enter your phone number';
    }
  }

  String get phoneNumberTooShort {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số điện thoại phải có ít nhất 10 số';
      default:
        return 'Phone number must be at least 10 digits';
    }
  }

  String get registrationFailed {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đăng ký thất bại. Vui lòng thử lại.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  String get loginFailed {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
      default:
        return 'Login failed. Please check your credentials.';
    }
  }

  String get pleaseLoginToStartMining {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng đăng nhập để bắt đầu đào';
      default:
        return 'Please login to start mining';
    }
  }

  String get miningActive {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đang đào';
      default:
        return 'Mining Active';
    }
  }

  String get miningStopped {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đã dừng';
      default:
        return 'Mining Stopped';
    }
  }

  String get duration {
    switch (locale.languageCode) {
      case 'vi':
        return 'Thời gian';
      default:
        return 'Duration';
    }
  }

  String get speed {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tốc độ';
      default:
        return 'Speed';
    }
  }

  String get walletBalance {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số dư ví';
      default:
        return 'Wallet Balance';
    }
  }

  String get refresh {
    switch (locale.languageCode) {
      case 'vi':
        return 'Làm mới';
      default:
        return 'Refresh';
    }
  }

  String get miningTips {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mẹo đào coin';
      default:
        return 'Mining Tips';
    }
  }

  String get miningTip1 {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đào coin mỗi ngày để tăng tốc độ đào';
      default:
        return 'Mine daily to increase your mining speed';
    }
  }

  String get miningTip2 {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mời bạn bè để tăng tốc độ đào';
      default:
        return 'Invite friends to boost mining speed';
    }
  }

  String get miningTip3 {
    switch (locale.languageCode) {
      case 'vi':
        return 'Xem video để nhận thưởng';
      default:
        return 'Watch videos to earn rewards';
    }
  }

  String get inviteFriends {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mời bạn bè';
      default:
        return 'Invite Friends';
    }
  }

  String get referralCode {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mã giới thiệu';
      default:
        return 'Referral Code';
    }
  }

  String get copyReferralCode {
    switch (locale.languageCode) {
      case 'vi':
        return 'Sao chép mã giới thiệu';
      default:
        return 'Copy Referral Code';
    }
  }

  String get totalReferrals {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tổng số bạn bè đã mời';
      default:
        return 'Total Referrals';
    }
  }

  String get speedBonus {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tăng tốc độ';
      default:
        return 'Speed Bonus';
    }
  }

  String get transferInternal {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chuyển nội bộ';
      default:
        return 'Internal Transfer';
    }
  }

  String get transferToBNB {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chuyển qua BNB';
      default:
        return 'Transfer to BNB';
    }
  }

  String get recipientWalletAddress {
    switch (locale.languageCode) {
      case 'vi':
        return 'Địa chỉ ví người nhận';
      default:
        return 'Recipient Wallet Address';
    }
  }

  String get amount {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số lượng';
      default:
        return 'Amount';
    }
  }

  String get confirm {
    switch (locale.languageCode) {
      case 'vi':
        return 'Xác nhận';
      default:
        return 'Confirm';
    }
  }

  String get cancel {
    switch (locale.languageCode) {
      case 'vi':
        return 'Hủy';
      default:
        return 'Cancel';
    }
  }

  String get contact {
    switch (locale.languageCode) {
      case 'vi':
        return 'Liên hệ';
      default:
        return 'Contact';
    }
  }

  String get contactUs {
    switch (locale.languageCode) {
      case 'vi':
        return 'Liên hệ với chúng tôi';
      default:
        return 'Contact Us';
    }
  }

  String get advertisementContact {
    switch (locale.languageCode) {
      case 'vi':
        return 'Liên hệ quảng cáo';
      default:
        return 'Advertisement Contact';
    }
  }

  String get requiresKYC {
    switch (locale.languageCode) {
      case 'vi':
        return 'Yêu cầu KYC';
      default:
        return 'Requires KYC';
    }
  }

  String get transferSuccessful {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chuyển coin thành công';
      default:
        return 'Transfer successful';
    }
  }

  String get transferFailed {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chuyển coin thất bại';
      default:
        return 'Transfer failed';
    }
  }

  String get insufficientBalance {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số dư không đủ';
      default:
        return 'Insufficient balance';
    }
  }

  String get invalidWalletAddress {
    switch (locale.languageCode) {
      case 'vi':
        return 'Địa chỉ ví không hợp lệ';
      default:
        return 'Invalid wallet address';
    }
  }

  String get pleaseEnterAmount {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập số lượng';
      default:
        return 'Please enter amount';
    }
  }

  String get pleaseEnterWalletAddress {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập địa chỉ ví';
      default:
        return 'Please enter wallet address';
    }
  }

  String get videoViews {
    switch (locale.languageCode) {
      case 'vi':
        return 'Lượt xem';
      default:
        return 'Views';
    }
  }

  String get copied {
    switch (locale.languageCode) {
      case 'vi':
        return 'Đã sao chép';
      default:
        return 'Copied';
    }
  }

  String get referralCodeOptional {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mã giới thiệu (tùy chọn)';
      default:
        return 'Referral Code (Optional)';
    }
  }

  String get enterReferralCode {
    switch (locale.languageCode) {
      case 'vi':
        return 'Nhập mã giới thiệu nếu có';
      default:
        return 'Enter referral code if you have one';
    }
  }

  String get invalidReferralCode {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mã giới thiệu không hợp lệ';
      default:
        return 'Invalid referral code';
    }
  }

  String get referralCodeApplied {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mã giới thiệu đã được áp dụng';
      default:
        return 'Referral code applied';
    }
  }

  String get friendsList {
    switch (locale.languageCode) {
      case 'vi':
        return 'Danh sách bạn bè';
      default:
        return 'Friends List';
    }
  }

  String get noFriends {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chưa có bạn bè';
      default:
        return 'No friends yet';
    }
  }

  String get inviteFriendsToGetStarted {
    switch (locale.languageCode) {
      case 'vi':
        return 'Mời bạn bè để bắt đầu kiếm thưởng!';
      default:
        return 'Invite friends to get started earning rewards!';
    }
  }

  String get yourReferrals {
    switch (locale.languageCode) {
      case 'vi':
        return 'Bạn bè của bạn';
      default:
        return 'Your Referrals';
    }
  }

  String get referredYou {
    switch (locale.languageCode) {
      case 'vi':
        return 'Người giới thiệu bạn';
      default:
        return 'Referred You';
    }
  }

  String get kyc {
    switch (locale.languageCode) {
      case 'vi':
        return 'KYC';
      default:
        return 'KYC';
    }
  }

  String get kycVerification {
    switch (locale.languageCode) {
      case 'vi':
        return 'Xác minh danh tính';
      default:
        return 'Identity Verification';
    }
  }

  String get idCardNumber {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số CMND/CCCD';
      default:
        return 'ID Card Number';
    }
  }

  String get idCardFrontPhoto {
    switch (locale.languageCode) {
      case 'vi':
        return 'Ảnh mặt trước CMND/CCCD';
      default:
        return 'ID Card Front Photo';
    }
  }

  String get idCardBackPhoto {
    switch (locale.languageCode) {
      case 'vi':
        return 'Ảnh mặt sau CMND/CCCD';
      default:
        return 'ID Card Back Photo';
    }
  }

  String get selfiePhoto {
    switch (locale.languageCode) {
      case 'vi':
        return 'Ảnh selfie cầm CMND/CCCD';
      default:
        return 'Selfie with ID Card';
    }
  }

  String get bankName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tên ngân hàng';
      default:
        return 'Bank Name';
    }
  }

  String get bankAccountNumber {
    switch (locale.languageCode) {
      case 'vi':
        return 'Số tài khoản ngân hàng';
      default:
        return 'Bank Account Number';
    }
  }

  String get bankAccountName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tên chủ tài khoản';
      default:
        return 'Account Holder Name';
    }
  }

  String get uploadPhoto {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tải ảnh lên';
      default:
        return 'Upload Photo';
    }
  }

  String get takePhoto {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chụp ảnh';
      default:
        return 'Take Photo';
    }
  }

  String get chooseFromGallery {
    switch (locale.languageCode) {
      case 'vi':
        return 'Chọn từ thư viện';
      default:
        return 'Choose from Gallery';
    }
  }

  String get submit {
    switch (locale.languageCode) {
      case 'vi':
        return 'Gửi';
      default:
        return 'Submit';
    }
  }

  String get kycInformation {
    switch (locale.languageCode) {
      case 'vi':
        return 'Thông tin KYC';
      default:
        return 'KYC Information';
    }
  }

  String get personalInformation {
    switch (locale.languageCode) {
      case 'vi':
        return 'Thông tin cá nhân';
      default:
        return 'Personal Information';
    }
  }

  String get bankInformation {
    switch (locale.languageCode) {
      case 'vi':
        return 'Thông tin ngân hàng';
      default:
        return 'Bank Information';
    }
  }

  String get photoDocuments {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tài liệu hình ảnh';
      default:
        return 'Photo Documents';
    }
  }

  String get pleaseEnterIdCardNumber {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập số CMND/CCCD';
      default:
        return 'Please enter ID card number';
    }
  }

  String get pleaseEnterBankName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập tên ngân hàng';
      default:
        return 'Please enter bank name';
    }
  }

  String get pleaseEnterBankAccountNumber {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập số tài khoản';
      default:
        return 'Please enter account number';
    }
  }

  String get pleaseEnterBankAccountName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Vui lòng nhập tên chủ tài khoản';
      default:
        return 'Please enter account holder name';
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
