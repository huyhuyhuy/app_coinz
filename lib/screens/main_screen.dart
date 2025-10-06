import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/language_selector.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/mining_reward_widget.dart';
import '../test_database.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    const HomeTab(),
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
      body: _tabs[_currentIndex],
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
            label: localizations.mining,
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
        return localizations.mining;
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

// Placeholder tabs - will be implemented in next phase
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.welcomeMessage,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stats',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          Icons.monetization_on,
                          '0',
                          localizations.coinsMined,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          Icons.speed,
                          '0',
                          localizations.miningSpeed,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          Icons.access_time,
                          '0h',
                          localizations.onlineTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Banner quảng cáo
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MiningTab extends StatelessWidget {
  const MiningTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 64,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mining Center',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Đào coin và kiếm thưởng từ video',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Widget xem video kiếm thưởng
          MiningRewardWidget(),
        ],
      ),
    );
  }
}

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Wallet Tab - Coming Soon',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          // Banner quảng cáo ở cuối
          BannerAdWidget(),
        ],
      ),
    );
  }
}

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Friends Tab - Coming Soon',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          // Banner quảng cáo ở cuối
          BannerAdWidget(),
        ],
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
            leading: const Icon(Icons.storage, color: Colors.blue),
            title: const Text('Test Database'),
            subtitle: const Text('Test SQLite database'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TestDatabaseScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.settings),
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(localizations.share),
            onTap: () {
              // TODO: Implement share functionality
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
          const SizedBox(height: 20),
          // Banner quảng cáo ở cuối
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
