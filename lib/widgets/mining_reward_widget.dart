import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Added for Timer

class MiningRewardWidget extends StatefulWidget {
  const MiningRewardWidget({super.key});

  @override
  State<MiningRewardWidget> createState() => _MiningRewardWidgetState();
}

class _MiningRewardWidgetState extends State<MiningRewardWidget> {
  bool _isVideoPlaying = false;
  bool _canExit = false;
  bool _rewardClaimed = false;
  double _currentMiningSpeed = 0.0;
  DateTime? _rewardExpiryTime;
  
  // YouTube video ID từ URL: https://www.youtube.com/shorts/UE_DQQgF-_M
  static const String _videoId = 'UE_DQQgF-_M';
  
  late YoutubePlayerController _controller;
  late Timer _watchTimer;
  int _watchSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadRewardData();
    _initializeVideoController();
  }

  void _loadRewardData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentMiningSpeed = prefs.getDouble('mining_speed') ?? 0.0;
      final expiryTimestamp = prefs.getInt('reward_expiry_time');
      if (expiryTimestamp != null) {
        _rewardExpiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      }
    });
  }

  void _initializeVideoController() {
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
        forceHD: true,
        enableCaption: false,
      ),
    );
  }

  void _startWatchingVideo() {
    setState(() {
      _isVideoPlaying = true;
      _canExit = false;
      _rewardClaimed = false;
      _watchSeconds = 0;
    });

    _controller.play();
    
    // Bắt đầu đếm thời gian xem video
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_watchSeconds < 10) {
        setState(() {
          _watchSeconds++;
        });
      } else {
        timer.cancel();
        setState(() {
          _canExit = true;
        });
      }
    });
  }

  void _exitVideo() {
    if (_canExit && !_rewardClaimed) {
      _claimReward();
    }
    
    setState(() {
      _isVideoPlaying = false;
    });
    
    _controller.pause();
    _watchTimer.cancel();
  }

  void _claimReward() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSpeed = prefs.getDouble('mining_speed') ?? 0.0;
    final newSpeed = currentSpeed + 0.1; // Tăng 0.1%
    
    // Lưu tốc độ mới và thời gian hết hạn (1 ngày)
    final expiryTime = DateTime.now().add(const Duration(days: 1));
    
    await prefs.setDouble('mining_speed', newSpeed);
    await prefs.setInt('reward_expiry_time', expiryTime.millisecondsSinceEpoch);
    
    setState(() {
      _currentMiningSpeed = newSpeed;
      _rewardExpiryTime = expiryTime;
      _rewardClaimed = true;
    });

    // Hiển thị thông báo nhận thưởng
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Nhận thưởng thành công! Tốc độ đào tăng lên ${newSpeed.toStringAsFixed(1)}%'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getRemainingTime() {
    if (_rewardExpiryTime == null) return 'Không có phần thưởng';
    
    final now = DateTime.now();
    if (now.isAfter(_rewardExpiryTime!)) {
      return 'Phần thưởng đã hết hạn';
    }
    
    final remaining = _rewardExpiryTime!.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }

  @override
  void dispose() {
    _controller.dispose();
    _watchTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideoPlaying) {
      return _buildVideoPlayer();
    }

    return _buildRewardInfo();
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
          ),
          if (_canExit)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _exitVideo,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          if (!_canExit)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Xem thêm ${10 - _watchSeconds} giây để nhận thưởng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
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
        children: [
          Icon(
            Icons.video_library,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Xem Video Kiếm Thưởng',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Xem video 10 giây để nhận phần thưởng',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Thông tin phần thưởng hiện tại
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tốc độ đào hiện tại:',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${_currentMiningSpeed.toStringAsFixed(1)}%',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời gian còn lại:',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _getRemainingTime(),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _rewardExpiryTime != null && 
                               DateTime.now().isBefore(_rewardExpiryTime!)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Nút xem video
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _startWatchingVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Xem Video',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
