import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/mining_reward_widget.dart';

class MiningTab extends StatefulWidget {
  const MiningTab({super.key});

  @override
  State<MiningTab> createState() => _MiningTabState();
}

class _MiningTabState extends State<MiningTab> {
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                localizations.locale.languageCode == 'vi'
                    ? 'Kiếm thưởng'
                    : 'Earn Rewards',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                localizations.locale.languageCode == 'vi'
                    ? 'Xem video để nhận phần thưởng COINZ'
                    : 'Watch videos to earn COINZ rewards',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              // Video Reward Widget
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

