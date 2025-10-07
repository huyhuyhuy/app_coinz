import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/video_ad_model.dart';
import '../repositories/video_ad_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class MiningRewardWidget extends StatefulWidget {
  const MiningRewardWidget({super.key});

  @override
  State<MiningRewardWidget> createState() => _MiningRewardWidgetState();
}

class _MiningRewardWidgetState extends State<MiningRewardWidget> {
  bool _isVideoPlaying = false;
  bool _canClaimReward = false;
  bool _rewardClaimed = false;
  double _currentMiningSpeed = 0.0;
  DateTime? _rewardExpiryTime;

  VideoAdModel? _currentVideo;
  bool _isLoadingVideo = false;
  String? _errorMessage;

  YoutubePlayerController? _controller;
  Timer? _watchTimer;
  int _watchSeconds = 0;
  static const int _requiredWatchSeconds = 30; // Yêu cầu xem 30 giây
  DateTime? _videoStartTime;

  final VideoAdRepository _videoAdRepo = VideoAdRepository();

  @override
  void initState() {
    super.initState();
    _loadRewardData();
    _loadVideoFromSupabase();
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

  Future<void> _loadVideoFromSupabase() async {
    setState(() {
      _isLoadingVideo = true;
      _errorMessage = null;
    });

    try {
      print('[VIDEO_AD] 🎬 Loading video from Supabase...');
      final video = await _videoAdRepo.getRandomActiveVideo();

      if (video != null) {
        print('[VIDEO_AD] ✅ Video loaded: ${video.videoTitle}');
        print('[VIDEO_AD] 💰 Reward: ${video.rewardAmount} COINZ');
        print('[VIDEO_AD] 🔗 URL: ${video.videoUrl}');

        setState(() {
          _currentVideo = video;
          _isLoadingVideo = false;
        });

        _initializeVideoController(video.videoUrl);
      } else {
        print('[VIDEO_AD] ⚠️ No active video available');
        setState(() {
          _errorMessage = 'No video available at the moment';
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      print('[VIDEO_AD] ❌ Error loading video: $e');
      setState(() {
        _errorMessage = 'Failed to load video: $e';
        _isLoadingVideo = false;
      });
    }
  }

  void _initializeVideoController(String videoUrl) {
    // Extract YouTube video ID from URL
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    if (videoId == null) {
      print('[VIDEO_AD] ❌ Invalid YouTube URL: $videoUrl');
      setState(() {
        _errorMessage = 'Invalid video URL';
      });
      return;
    }

    print('[VIDEO_AD] 🎥 Initializing player with video ID: $videoId');

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
        forceHD: true,
        enableCaption: false,
      ),
    );

    // Listen to player state changes
    _controller!.addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (_controller == null) return;

    final isPlaying = _controller!.value.isPlaying;

    // Chỉ đếm thời gian khi video đang thực sự chạy
    if (isPlaying && _isVideoPlaying && _watchTimer == null) {
      print('[VIDEO_AD] ▶️ Video is playing, starting timer...');
      _startWatchTimer();
    } else if (!isPlaying && _watchTimer != null) {
      print('[VIDEO_AD] ⏸️ Video paused, stopping timer...');
      _stopWatchTimer();
    }
  }

  void _startWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller?.value.isPlaying == true) {
        setState(() {
          _watchSeconds++;
        });

        print('[VIDEO_AD] ⏱️ Watch time: ${_watchSeconds}s / ${_requiredWatchSeconds}s');

        if (_watchSeconds >= _requiredWatchSeconds) {
          timer.cancel();
          setState(() {
            _canClaimReward = true;
          });
          print('[VIDEO_AD] ✅ Required watch time reached (${_requiredWatchSeconds}s)');
        }
      }
    });
  }

  void _stopWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  void _startWatchingVideo() {
    if (_currentVideo == null || _controller == null) {
      print('[VIDEO_AD] ❌ Cannot start video: video or controller is null');
      return;
    }

    setState(() {
      _isVideoPlaying = true;
      _canClaimReward = false;
      _rewardClaimed = false;
      _watchSeconds = 0;
      _videoStartTime = DateTime.now();
    });

    print('[VIDEO_AD] ▶️ Starting video playback...');
    _controller!.play();
  }

  void _exitVideo() {
    if (_canClaimReward && !_rewardClaimed) {
      _claimReward();
    }

    setState(() {
      _isVideoPlaying = false;
    });

    _controller?.pause();
    _stopWatchTimer();
  }

  void _claimReward() async {
    if (_currentVideo == null || _videoStartTime == null) {
      print('[VIDEO_AD] ❌ Cannot claim reward: video or start time is null');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (authProvider.userId == null) {
      print('[VIDEO_AD] ❌ Cannot claim reward: user not logged in');
      return;
    }

    // Tính thời gian xem video (dùng _watchSeconds vì đã đếm chính xác)
    final watchDuration = _watchSeconds;
    final completed = watchDuration >= _requiredWatchSeconds;

    print('[VIDEO_AD] 💰 Claiming reward...');
    print('[VIDEO_AD] 👤 User ID: ${authProvider.userId}');
    print('[VIDEO_AD] 🎬 Video ID: ${_currentVideo!.adId}');
    print('[VIDEO_AD] ⏱️ Watch duration: ${watchDuration}s');
    print('[VIDEO_AD] ✅ Completed: $completed');

    try {
      // Record view to Supabase
      final success = await _videoAdRepo.recordVideoView(
        userId: authProvider.userId!,
        adId: _currentVideo!.adId,
        rewardAmount: _currentVideo!.rewardAmount,
        viewDuration: watchDuration,
        completed: completed,
      );

      if (success) {
        print('[VIDEO_AD] ✅ View recorded successfully');

        // Update wallet balance
        await walletProvider.refresh(authProvider.userId!);

        // Update local mining speed (for UI display)
        final prefs = await SharedPreferences.getInstance();
        final currentSpeed = prefs.getDouble('mining_speed') ?? 0.0;
        final newSpeed = currentSpeed + 0.1;
        final expiryTime = DateTime.now().add(const Duration(days: 1));

        await prefs.setDouble('mining_speed', newSpeed);
        await prefs.setInt('reward_expiry_time', expiryTime.millisecondsSinceEpoch);

        // Check mounted before setState
        if (mounted) {
          setState(() {
            _currentMiningSpeed = newSpeed;
            _rewardExpiryTime = expiryTime;
            _rewardClaimed = true;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Nhận thưởng thành công! +${_currentVideo!.rewardAmount.toStringAsFixed(8)} COINZ'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('[VIDEO_AD] ❌ Failed to record view');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Không thể ghi nhận lượt xem'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('[VIDEO_AD] ❌ Error claiming reward: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
    _controller?.removeListener(_onPlayerStateChange);
    _controller?.dispose();
    _stopWatchTimer();
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
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
              controller: _controller!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
          ),
          // Vòng tròn đếm ngược (hiển thị khi chưa đủ thời gian)
          if (!_canClaimReward)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vòng tròn progress
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        value: _watchSeconds / _requiredWatchSeconds,
                        strokeWidth: 2.5,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
                      ),
                    ),
                    // Số giây còn lại
                    Text(
                      '${_requiredWatchSeconds - _watchSeconds}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Nút đóng (hiển thị khi đã đủ thời gian)
          if (_canClaimReward)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _exitVideo,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardInfo() {
    // Show loading state
    if (_isLoadingVideo) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
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
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Đang tải video...',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
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
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải video',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadVideoFromSupabase,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Show video info
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
            _currentVideo?.videoTitle ?? 'Xem Video Kiếm Thưởng',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Xem video ${_requiredWatchSeconds} giây để nhận ${_currentVideo?.rewardAmount.toStringAsFixed(8) ?? '0.00000000'} COINZ',
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
                    Flexible(
                      child: Text(
                        'Tốc độ đào hiện tại:',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentMiningSpeed.toStringAsFixed(1)}%',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
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
                    Flexible(
                      child: Text(
                        'Thời gian còn lại:',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getRemainingTime(),
                      style: GoogleFonts.roboto(
                        fontSize: 13,
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
              onPressed: _currentVideo != null && _controller != null ? _startWatchingVideo : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    _currentVideo != null ? 'Xem Video' : 'Đang tải...',
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
