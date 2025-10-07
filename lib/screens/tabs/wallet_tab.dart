import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/banner_ad_widget.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  bool _isInitialized = false;

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
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (authProvider.userId != null) {
      // Use addPostFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        walletProvider.initialize(authProvider.userId!);
      });
    }
  }

  void _copyWalletAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).locale.languageCode == 'vi'
              ? 'Đã sao chép địa chỉ ví'
              : 'Wallet address copied',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Consumer2<AuthProvider, WalletProvider>(
      builder: (context, authProvider, walletProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
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
                      Text(
                        localizations.totalBalance,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${walletProvider.formattedBalanceShort} COINZ',
                        style: GoogleFonts.roboto(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              walletProvider.shortWalletAddress,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                            onPressed: () {
                              _copyWalletAddress(
                                context,
                                walletProvider.wallet?.walletAddress ?? '',
                              );
                            },
                            tooltip: localizations.locale.languageCode == 'vi'
                                ? 'Sao chép địa chỉ'
                                : 'Copy address',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Withdraw Button (disabled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null, // Disabled for now
                  icon: const Icon(Icons.account_balance_wallet),
                  label: Text(
                    '${localizations.withdraw} (${localizations.comingSoon})',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Transaction History Section
              Text(
                localizations.locale.languageCode == 'vi'
                    ? 'Lịch sử giao dịch'
                    : 'Transaction History',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Incoming Transactions (Mining rewards)
              Card(
                child: ExpansionTile(
                  leading: Icon(Icons.arrow_downward, color: Colors.green[600]),
                  title: Text(
                    localizations.locale.languageCode == 'vi'
                        ? 'Giao dịch đến'
                        : 'Incoming Transactions',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildTransactionItem(
                            context,
                            localizations.locale.languageCode == 'vi'
                                ? 'Phần thưởng đào coin'
                                : 'Mining Rewards',
                            '+ ${walletProvider.wallet?.totalEarned.toStringAsFixed(8) ?? '0.00000000'} COINZ',
                            Icons.monetization_on,
                            Colors.green,
                          ),
                          const Divider(),
                          Center(
                            child: Text(
                              localizations.locale.languageCode == 'vi'
                                  ? 'Xem tất cả giao dịch đến'
                                  : 'View all incoming transactions',
                              style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Outgoing Transactions (Coming soon)
              Card(
                child: ExpansionTile(
                  leading: Icon(Icons.arrow_upward, color: Colors.red[600]),
                  title: Text(
                    localizations.locale.languageCode == 'vi'
                        ? 'Giao dịch đi'
                        : 'Outgoing Transactions',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.send,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              localizations.comingSoon,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Banner Ad
              const BannerAdWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

