import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../providers/auth_provider.dart';
import '../providers/mining_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/language_selector.dart';
import '../widgets/banner_ad_widget.dart';
import '../repositories/friends_repository.dart';
import '../repositories/user_repository.dart';
import '../services/storage_service.dart';
import 'tabs/home_tab.dart';
import 'tabs/mining_tab.dart';
import 'tabs/wallet_tab.dart';
import 'kyc_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _tabs => [
    HomeTab(onNavigateToWallet: () => _navigateToTab(2)),
    const MiningTab(),
    const WalletTab(),
    const FriendsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTabTitle(_currentIndex, localizations),
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ✅ FIX: Không hiển thị back button trên main screen
        automaticallyImplyLeading: false,
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _tabs[_currentIndex],
          ),
          // Banner Ad - Always visible above bottom nav
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monetization_on_outlined),
            activeIcon: const Icon(Icons.monetization_on),
            label: localizations.task,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: localizations.wallet,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outlined),
            activeIcon: const Icon(Icons.people),
            label: localizations.friends,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index, AppLocalizations localizations) {
    switch (index) {
      case 0:
        return localizations.home;
      case 1:
        return localizations.task;
      case 2:
        return localizations.wallet;
      case 3:
        return localizations.friends;
      case 4:
        return localizations.profile;
      default:
        return localizations.home;
    }
  }
}

// Friends Tab - Hiển thị danh sách bạn bè
class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.userId == null) {
          return Center(
            child: Text(localizations.pleaseLoginToStartMining),
          );
        }

        return FutureBuilder<List<dynamic>>(
          future: _loadFriendsData(authProvider.userId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final data = snapshot.data;
            if (data == null || data.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noFriends,
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.inviteFriendsToGetStarted,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final referrer = data[0] as dynamic; // Người giới thiệu (nếu có)
            final referrals = data[1] as List<dynamic>; // Những người mình giới thiệu

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Người giới thiệu bạn (nếu có)
                  if (referrer != null) ...[
                    Text(
                      localizations.referredYou,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFriendCard(context, referrer, isReferrer: true),
                    const SizedBox(height: 24),
                  ],

                  // Danh sách người bạn đã giới thiệu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.yourReferrals,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${referrals.length} ${localizations.locale.languageCode == 'vi' ? 'bạn bè' : 'friends'}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (referrals.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          localizations.locale.languageCode == 'vi'
                              ? 'Bạn chưa giới thiệu ai'
                              : 'You haven\'t referred anyone yet',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    )
                  else
                    ...referrals.map((friend) => _buildFriendCard(context, friend)).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _loadFriendsData(String userId) async {
    final friendsRepo = FriendsRepository();
    
    final referrer = await friendsRepo.getUserReferrer(userId);
    final referrals = await friendsRepo.getUserReferrals(userId);
    
    return [referrer, referrals];
  }

  Widget _buildFriendCard(BuildContext context, FriendInfo friend, {bool isReferrer = false}) {
    final avatarUrl = friend.user.avatarUrl;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: isReferrer 
                  ? Colors.purple.shade100
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                      friend.user.initials,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isReferrer 
                            ? Colors.purple.shade700
                            : Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          friend.user.fullName,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isReferrer) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '⭐ Referrer',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // ✅ VẤN ĐỀ 3: Chỉ hiển thị trạng thái online/offline, ẩn coin và tốc độ
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: friend.isOnline ? Colors.green : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        friend.isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: friend.isOnline ? Colors.green[700] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isUploadingAvatar = false;
  final ImagePicker _imagePicker = ImagePicker();
  final UserRepository _userRepo = UserRepository();

  /// Pick, crop và upload avatar
  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userId == null) return;

    try {
      // Show options: Camera or Gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(localizations.locale.languageCode == 'vi'
                    ? 'Chụp ảnh'
                    : 'Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(localizations.locale.languageCode == 'vi'
                    ? 'Chọn từ thư viện'
                    : 'Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Crop image thành hình vuông (Version 8.x API)
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Hình vuông
        compressQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: localizations.locale.languageCode == 'vi'
                ? 'Chỉnh sửa ảnh đại diện'
                : 'Edit Avatar',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: localizations.locale.languageCode == 'vi'
                ? 'Chỉnh sửa ảnh đại diện'
                : 'Edit Avatar',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      // Start uploading
      setState(() {
        _isUploadingAvatar = true;
      });

      // Validate file
      final imageFile = File(croppedFile.path);
      final validationError = StorageService.validateImageFile(imageFile);
      
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploadingAvatar = false;
        });
        return;
      }

      // Upload to Supabase Storage
      final avatarUrl = await StorageService.uploadAvatar(
        userId: authProvider.userId!,
        imageFile: imageFile,
      );

      if (avatarUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.locale.languageCode == 'vi'
                  ? 'Upload ảnh thất bại'
                  : 'Failed to upload avatar'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploadingAvatar = false;
        });
        return;
      }

      // Update avatar_url in database
      final success = await _userRepo.updateAvatarUrl(
        authProvider.userId!,
        avatarUrl,
      );

      setState(() {
        _isUploadingAvatar = false;
      });

      if (success && mounted) {
        // Refresh current user data để cập nhật avatar URL
        await authProvider.refreshCurrentUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.locale.languageCode == 'vi'
                ? '✅ Cập nhật ảnh đại diện thành công!'
                : '✅ Avatar updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.locale.languageCode == 'vi'
                ? 'Lưu ảnh đại diện thất bại'
                : 'Failed to save avatar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[PROFILE_TAB] ❌ Error uploading avatar: $e');
      
      setState(() {
        _isUploadingAvatar = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final avatarUrl = authProvider.currentUser?.avatarUrl;
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar với camera icon
                      Stack(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Text(
                                    authProvider.userName?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          
                          // Camera icon button (góc dưới bên phải)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _isUploadingAvatar ? null : () => _pickAndUploadAvatar(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isUploadingAvatar
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.userName ?? 'User',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        authProvider.userEmail ?? 'user@example.com',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final prefs = snapshot.data!;
                            final phone = prefs.getString('user_phone');
                            if (phone != null) {
                              return Text(
                                '📱 $phone',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: Text(localizations.kyc),
            subtitle: Text(
              localizations.kycVerification,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const KYCScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: Text(localizations.contact),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(localizations.contactUs),
                  content: const Text('devtest@gmail.com'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(localizations.logout),
            onTap: () async {
              // ✅ VẤN ĐỀ 5: Reset toàn bộ providers khi logout
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final walletProvider = Provider.of<WalletProvider>(context, listen: false);
              final miningProvider = Provider.of<MiningProvider>(context, listen: false);
              
              // Stop mining nếu đang chạy
              if (miningProvider.isMining && authProvider.userId != null) {
                await miningProvider.stopMining(authProvider.userId!);
              }
              
              // Reset providers
              walletProvider.reset();
              miningProvider.reset();
              
              // Logout auth (clear database & prefs)
              await authProvider.logout();
              
              if (context.mounted) {
                // ✅ FIX: Clear toàn bộ navigation stack và về LoginScreen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // Remove all routes
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
