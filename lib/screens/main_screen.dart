import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/language_selector.dart';
import '../widgets/banner_ad_widget.dart';
import '../repositories/friends_repository.dart';
import 'tabs/home_tab.dart';
import 'tabs/mining_tab.dart';
import 'tabs/wallet_tab.dart';
import 'kyc_screen.dart';

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
              child: Text(
                friend.user.initials,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isReferrer 
                      ? Colors.purple.shade700
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      Icon(Icons.monetization_on, size: 14, color: Colors.orange[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${friend.formattedBalance} COINZ',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.speed, size: 14, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${friend.formattedSpeed}/s',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Online status
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: friend.isOnline ? Colors.green : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          authProvider.userName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
    );
  }
}
