import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mining_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/mining_reward_widget.dart';

class MiningTab extends StatefulWidget {
  const MiningTab({super.key});

  @override
  State<MiningTab> createState() => _MiningTabState();
}

class _MiningTabState extends State<MiningTab> {
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
    final miningProvider = Provider.of<MiningProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    if (authProvider.userId != null) {
      await miningProvider.initialize(authProvider.userId!);
      await walletProvider.initialize(authProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Consumer3<AuthProvider, MiningProvider, WalletProvider>(
      builder: (context, authProvider, miningProvider, walletProvider, child) {
        if (authProvider.userId == null) {
          return Center(
            child: Text(localizations.pleaseLoginToStartMining),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Mining Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Mining Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: miningProvider.isMining
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          size: 60,
                          color: miningProvider.isMining
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Status Text
                      Text(
                        miningProvider.isMining ? localizations.miningActive : localizations.miningStopped,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: miningProvider.isMining
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mining Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            localizations.coinsMined,
                            miningProvider.formattedCoins,
                            Icons.monetization_on,
                            Colors.orange,
                          ),
                          _buildStatColumn(
                            localizations.duration,
                            miningProvider.formattedDuration,
                            Icons.access_time,
                            Colors.blue,
                          ),
                          _buildStatColumn(
                            localizations.speed,
                            '${miningProvider.formattedSpeed}/s',
                            Icons.speed,
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Start/Stop Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (miningProvider.isMining) {
                              await miningProvider.stopMining(authProvider.userId!);
                              await walletProvider.refresh(authProvider.userId!);
                            } else {
                              await miningProvider.startMining(authProvider.userId!);
                            }
                          },
                          icon: Icon(
                            miningProvider.isMining ? Icons.stop : Icons.play_arrow,
                            size: 28,
                          ),
                          label: Text(
                            miningProvider.isMining ? localizations.stopMining : localizations.startMining,
                            style: const TextStyle(
                              fontSize: 18,
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
              
              // Wallet Balance Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.walletBalance,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${walletProvider.formattedBalanceShort} COINZ',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await walletProvider.refresh(authProvider.userId!);
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Mining Reward Widget (Watch videos for bonus)
              const MiningRewardWidget(),
              const SizedBox(height: 20),
              
              // Mining Tips
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            localizations.miningTips,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('⛏️ ${localizations.miningTip1}'),
                      _buildTip('📹 ${localizations.miningTip3}'),
                      _buildTip('👥 ${localizations.miningTip2}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.roboto(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

