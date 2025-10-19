import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_localizations.dart';

class InviteFriendsWidget extends StatefulWidget {
  const InviteFriendsWidget({super.key});

  @override
  State<InviteFriendsWidget> createState() => _InviteFriendsWidgetState();
}

class _InviteFriendsWidgetState extends State<InviteFriendsWidget> {
  bool _isExpanded = false; // Collapse by default

  void _copyReferralCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).locale.languageCode == 'vi'
              ? 'Đã sao chép mã giới thiệu'
              : 'Referral code copied',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ✅ VẤN ĐỀ 2: Cập nhật milestone mới
  String _getSpeedBonus(int referrals) {
    if (referrals >= 237) return 'x4';
    if (referrals >= 158) return 'x3';
    if (referrals >= 79) return 'x2';
    return 'x1';
  }

  Color _getBonusColor(int referrals) {
    if (referrals >= 237) return Colors.purple;
    if (referrals >= 158) return Colors.orange;
    if (referrals >= 79) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final referralCode = user?.referralCode ?? 'LOADING...';
        final totalReferrals = user?.totalReferrals ?? 0;
        final speedBonus = _getSpeedBonus(totalReferrals);
        final bonusColor = _getBonusColor(totalReferrals);

        if (!_isExpanded) {
          return _buildCollapsedView(context, localizations, speedBonus, bonusColor);
        }

        return _buildExpandedView(
          context, 
          localizations, 
          referralCode, 
          totalReferrals, 
          speedBonus, 
          bonusColor
        );
      },
    );
  }

  Widget _buildCollapsedView(
    BuildContext context,
    AppLocalizations localizations,
    String speedBonus,
    Color bonusColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isExpanded = true;
          });
        },
        icon: const Icon(Icons.people, size: 24),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                localizations.locale.languageCode == 'vi'
                    ? 'Mời bạn bè để tăng tốc độ đào'
                    : 'Invite friends to boost mining speed',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bonusColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                speedBonus,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildExpandedView(
    BuildContext context,
    AppLocalizations localizations,
    String referralCode,
    int totalReferrals,
    String speedBonus,
    Color bonusColor,
  ) {
    return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade50,
                Colors.teal.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.inviteFriends,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // Speed bonus badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bonusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: bonusColor, width: 1.5),
                    ),
                    child: Text(
                      speedBonus,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: bonusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    tooltip: 'Thu gọn',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Referral code card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.referralCode,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            referralCode,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyReferralCode(context, referralCode),
                          tooltip: localizations.copyReferralCode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.group,
                      totalReferrals.toString(),
                      localizations.totalReferrals,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.speed,
                      speedBonus,
                      localizations.speedBonus,
                      bonusColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Milestones
              _buildMilestones(context, totalReferrals),

              const SizedBox(height: 16),

              // Invite button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement share functionality
                    final message = localizations.locale.languageCode == 'vi'
                        ? 'Tham gia App Coinz và đào coin miễn phí! Sử dụng mã giới thiệu: $referralCode'
                        : 'Join App Coinz and mine coins for free! Use referral code: $referralCode';
                    
                    Clipboard.setData(ClipboardData(text: message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations.locale.languageCode == 'vi'
                              ? 'Đã sao chép lời mời'
                              : 'Invitation message copied',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, size: 20),
                  label: Text(
                    localizations.locale.languageCode == 'vi'
                        ? 'Chia sẻ mã giới thiệu'
                        : 'Share Referral Code',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
      ),
    );
  }

  /// ✅ VẤN ĐỀ 2: Cập nhật milestone mới
  Widget _buildMilestones(BuildContext context, int currentReferrals) {
    final milestones = [
      {'count': 79, 'bonus': 'x2', 'color': Colors.green},
      {'count': 158, 'bonus': 'x3', 'color': Colors.orange},
      {'count': 237, 'bonus': 'x4', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).locale.languageCode == 'vi'
              ? 'Mốc thưởng'
              : 'Milestones',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...milestones.map((milestone) {
          final count = milestone['count'] as int;
          final bonus = milestone['bonus'] as String;
          final color = milestone['color'] as Color;
          final isAchieved = currentReferrals >= count;
          final progress = currentReferrals < count 
              ? (currentReferrals / count).clamp(0.0, 1.0)
              : 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  isAchieved ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: isAchieved ? color : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$count ${AppLocalizations.of(context).locale.languageCode == 'vi' ? 'bạn bè' : 'friends'} → $bonus',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
                              color: isAchieved ? color : Colors.grey[600],
                            ),
                          ),
                          if (!isAchieved)
                            Text(
                              '$currentReferrals/$count',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAchieved ? color : color.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

