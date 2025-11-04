import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/video_carousel_widget.dart';
import '../../widgets/invite_friends_widget.dart';

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
              // Video Carousel Widget
              const VideoCarouselWidget(),

              const SizedBox(height: 16),

              // Invite Friends Widget
              const InviteFriendsWidget(),

              const SizedBox(height: 20),

              // Mining Tips
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16),
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

              const SizedBox(height: 20),

              // Advertisement Contact Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    localizations.locale.languageCode == 'vi'
                        ? 'Liên hệ quảng cáo: dongfi.helpdesk@gmail.com'
                        : 'Advertisement contact: dongfi.helpdesk@gmail.com',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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

