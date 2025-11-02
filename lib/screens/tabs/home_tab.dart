import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mining_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_localizations.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onNavigateToWallet;

  const HomeTab({super.key, required this.onNavigateToWallet});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miningProvider = Provider.of<MiningProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (authProvider.userId == null) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App is going to background - stop mining
        if (miningProvider.isMining) {
          print('[HOME_TAB] 🛑 App going to background - stopping mining');
          miningProvider.stopMining(authProvider.userId!).then((_) {
            walletProvider.refresh(authProvider.userId!);
          });
        }
        break;
      case AppLifecycleState.resumed:
        // App is back to foreground - no auto restart
        print('[HOME_TAB] ▶️ App resumed - mining will not auto-restart');
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _initializeProviders();
      _isInitialized = true;
    }
  }

  Future<void> _initializeProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miningProvider = Provider.of<MiningProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    if (authProvider.userId != null) {
      await miningProvider.initialize(authProvider.userId!);
      await walletProvider.initialize(authProvider.userId!);
    }
  }

  /// Extract tên (chữ cuối) từ full name
  /// VD: "Nguyen Van A" → "A"
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'User';
    
    // Lấy chữ cuối cùng (tên)
    return parts.last;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Consumer3<AuthProvider, MiningProvider, WalletProvider>(
      builder: (context, authProvider, miningProvider, walletProvider, child) {
        // Extract tên từ full name
        final firstName = _getFirstName(authProvider.userName);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message với avatar
              Row(
                children: [
                  // Avatar nhỏ
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: authProvider.currentUser?.avatarUrl != null &&
                            authProvider.currentUser!.avatarUrl!.isNotEmpty
                        ? NetworkImage(authProvider.currentUser!.avatarUrl!)
                        : null,
                    child: authProvider.currentUser?.avatarUrl == null ||
                            authProvider.currentUser!.avatarUrl!.isEmpty
                        ? Text(
                            firstName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Welcome text
                  Text(
                    localizations.locale.languageCode == 'vi'
                        ? '$firstName'
                        : '$firstName',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Wallet Balance Card (Clickable)
              InkWell(
                onTap: widget.onNavigateToWallet,
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  localizations.totalBalance,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${walletProvider.formattedBalanceShort} DFI',
                          style: GoogleFonts.roboto(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          walletProvider.shortWalletAddress,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Quick Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Stats',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: miningProvider.isMining
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: miningProvider.isMining
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  miningProvider.isMining ? 'Mining' : 'Idle',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: miningProvider.isMining
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              'assets/icons/mined_icon.png', // ✅ Dùng PNG icon
                              miningProvider.formattedCoins,
                              localizations.coinsMined,
                              Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              Icons.speed,
                              '${miningProvider.formattedSpeed}/s',
                              localizations.miningSpeed,
                              Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              Icons.access_time,
                              miningProvider.formattedDuration,
                              localizations.onlineTime,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Start/Stop Mining Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (miningProvider.isMining) {
                              await miningProvider.stopMining(authProvider.userId!);
                              await walletProvider.refresh(authProvider.userId!);
                            } else {
                              // Truyền totalReferrals để tính speed multiplier
                              await miningProvider.startMining(
                                authProvider.userId!,
                                totalReferrals: authProvider.currentUser?.totalReferrals ?? 0,
                              );
                            }
                          },
                          icon: Icon(
                            miningProvider.isMining ? Icons.stop : Icons.play_arrow,
                            size: 24,
                          ),
                          label: Text(
                            miningProvider.isMining
                                ? localizations.stopMining
                                : localizations.startMining,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: miningProvider.isMining
                                ? Colors.red
                                : Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    dynamic icon, // ✅ Hỗ trợ cả IconData và String (asset path)
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        // ✅ Hiển thị icon phù hợp: Material Icon hoặc PNG Asset
        icon is IconData
            ? Icon(
                icon,
                size: 32,
                color: color,
              )
            : Image.asset(
                icon as String,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

}

