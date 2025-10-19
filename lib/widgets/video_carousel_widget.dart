import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/video_ad_model.dart';
import '../repositories/video_ad_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

/// Enum để xác định loại video
enum VideoType {
  youtube,
  directMp4,
}

class VideoCarouselWidget extends StatefulWidget {
  const VideoCarouselWidget({super.key});

  @override
  State<VideoCarouselWidget> createState() => _VideoCarouselWidgetState();
}

class _VideoCarouselWidgetState extends State<VideoCarouselWidget> {
  bool _isExpanded = false;
  // ❌ Removed: bool _isVideoPlaying = false; (conflict with method _isVideoPlaying())
  
  List<VideoAdModel> _videos = [];
  int _currentVideoIndex = 0;
  bool _isLoadingVideos = false;
  String? _errorMessage;

  // ✅ Controllers cho cả YouTube và Direct MP4
  Map<int, YoutubePlayerController> _youtubeControllers = {};
  Map<int, VideoPlayerController> _mp4Controllers = {};
  Map<int, VideoType> _videoTypes = {};  // Track video type cho mỗi video
  
  Map<int, int> _watchSeconds = {};
  Map<int, bool> _videoClaimed = {};
  Map<int, bool> _isClaimingReward = {}; // Prevent multiple claim calls
  
  Timer? _watchTimer;
  static const int _requiredWatchSeconds = 30;

  final VideoAdRepository _videoAdRepo = VideoAdRepository();

  @override
  void initState() {
    super.initState();
    _loadVideosFromSupabase();
  }

  // ❌ Removed old dispose() - using new dispose() at end of file

  Future<void> _loadVideosFromSupabase() async {
    setState(() {
      _isLoadingVideos = true;
      _errorMessage = null;
    });

    try {
      print('[VIDEO_CAROUSEL] 🎬 Loading videos from Supabase...');
      final videos = await _videoAdRepo.getAllActiveVideos();

      if (videos.isNotEmpty) {
        print('[VIDEO_CAROUSEL] ✅ Loaded ${videos.length} videos');

        setState(() {
          _videos = videos;
          _isLoadingVideos = false;
        });

        // Initialize cho tất cả videos
        for (int i = 0; i < videos.length; i++) {
          _initializeVideoController(i, videos[i].videoUrl);
          _watchSeconds[i] = 0;
          _videoClaimed[i] = false;
          _isClaimingReward[i] = false;
        }
      } else {
        print('[VIDEO_CAROUSEL] ⚠️ No active videos available');
        setState(() {
          _errorMessage = 'No videos available at the moment';
          _isLoadingVideos = false;
        });
      }
    } catch (e) {
      print('[VIDEO_CAROUSEL] ❌ Error loading videos: $e');
      setState(() {
        _errorMessage = 'Failed to load videos: $e';
        _isLoadingVideos = false;
      });
    }
  }

  /// ✅ Detect video type và initialize appropriate controller
  void _initializeVideoController(int index, String videoUrl) {
    print('[VIDEO_CAROUSEL] 🎬 Initializing video $index: $videoUrl');
    
    // Detect video type
    final videoType = _detectVideoType(videoUrl);
    _videoTypes[index] = videoType;
    
    if (videoType == VideoType.youtube) {
      _initializeYouTubeController(index, videoUrl);
    } else {
      _initializeMp4Controller(index, videoUrl);
    }
  }
  
  /// Detect video type from URL
  VideoType _detectVideoType(String videoUrl) {
    // Check if YouTube URL
    final youtubeId = YoutubePlayer.convertUrlToId(videoUrl);
    if (youtubeId != null) {
      return VideoType.youtube;
    }
    
    // Check if direct video file (mp4, webm, etc.)
    final lowerUrl = videoUrl.toLowerCase();
    if (lowerUrl.endsWith('.mp4') || 
        lowerUrl.endsWith('.webm') || 
        lowerUrl.endsWith('.mov') ||
        lowerUrl.contains('/storage/v1/object/public/')) {  // Supabase storage
      return VideoType.directMp4;
    }
    
    // Default to YouTube
    return VideoType.youtube;
  }
  
  /// Initialize YouTube player controller
  void _initializeYouTubeController(int index, String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) {
      print('[VIDEO_CAROUSEL] ❌ Invalid YouTube URL: $videoUrl');
      return;
    }

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    controller.addListener(() => _onPlayerStateChange(index));
    _youtubeControllers[index] = controller;
    print('[VIDEO_CAROUSEL] ✅ YouTube controller initialized for video $index');
  }
  
  /// Initialize Direct MP4 player controller
  void _initializeMp4Controller(int index, String videoUrl) {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      // Initialize controller
      controller.initialize().then((_) {
        if (mounted) {
          setState(() {});
          print('[VIDEO_CAROUSEL] ✅ MP4 controller initialized for video $index');
        }
      }).catchError((error) {
        print('[VIDEO_CAROUSEL] ❌ Error initializing MP4 controller: $error');
      });
      
      // Add listener for state changes
      controller.addListener(() => _onMp4PlayerStateChange(index));
      
      _mp4Controllers[index] = controller;
    } catch (e) {
      print('[VIDEO_CAROUSEL] ❌ Error creating MP4 controller: $e');
    }
  }
  
  /// Handle YouTube player state changes
  void _onPlayerStateChange(int index) {
    if (index != _currentVideoIndex) return;
    
    final controller = _youtubeControllers[index];
    if (controller == null) return;

    if (controller.value.isPlaying && _watchTimer == null) {
      _startWatchTimer(index);
    } else if (!controller.value.isPlaying && _watchTimer != null) {
      _stopWatchTimer();
    }
  }
  
  /// Handle MP4 player state changes
  void _onMp4PlayerStateChange(int index) {
    if (index != _currentVideoIndex) return;
    
    final controller = _mp4Controllers[index];
    if (controller == null) return;

    if (controller.value.isPlaying && _watchTimer == null) {
      _startWatchTimer(index);
    } else if (!controller.value.isPlaying && _watchTimer != null) {
      _stopWatchTimer();
    }
  }


  void _startWatchTimer(int index) {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // ✅ Check video type để lấy đúng controller
      final isPlaying = _isVideoPlaying(index);
      
      if (isPlaying) {
        setState(() {
          _watchSeconds[index] = (_watchSeconds[index] ?? 0) + 1;
        });

        print('[VIDEO_CAROUSEL] ⏱️ Video $index watch time: ${_watchSeconds[index]}s / $_requiredWatchSeconds s');

        // Tự động claim khi đủ 30 giây
        if (_watchSeconds[index]! >= _requiredWatchSeconds && 
            !(_videoClaimed[index] ?? false) && 
            !(_isClaimingReward[index] ?? false)) {
          timer.cancel();
          _autoClaimReward(index);
        }
      }
    });
  }
  
  /// Check if video is currently playing
  bool _isVideoPlaying(int index) {
    final videoType = _videoTypes[index];
    
    if (videoType == VideoType.youtube) {
      return _youtubeControllers[index]?.value.isPlaying ?? false;
    } else {
      return _mp4Controllers[index]?.value.isPlaying ?? false;
    }
  }

  void _stopWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  Future<void> _autoClaimReward(int index) async {
    if (_videoClaimed[index] == true) {
      print('[VIDEO_CAROUSEL] ⚠️ Reward already claimed for video $index');
      return;
    }

    if (_isClaimingReward[index] == true) {
      print('[VIDEO_CAROUSEL] ⚠️ Already claiming reward for video $index');
      return;
    }

    print('[VIDEO_CAROUSEL] 💰 Auto-claiming reward for video $index...');
    
    // Set claiming flag
    _isClaimingReward[index] = true;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (authProvider.userId == null) return;

    final video = _videos[index];
    final watchDuration = _watchSeconds[index] ?? 0;
    final completed = watchDuration >= _requiredWatchSeconds;

    try {
      // ✅ VẤN ĐỀ 1: Check xem user đã xem video này trong ngày chưa
      final hasViewedToday = await _videoAdRepo.hasUserViewedToday(
        authProvider.userId!,
        video.adId,
      );

      if (hasViewedToday) {
        print('[VIDEO_CAROUSEL] ⚠️ Video đã được xem và nhận thưởng trong ngày hôm nay');
        
        setState(() {
          _videoClaimed[index] = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ Bạn đã xem video này hôm nay. Mỗi video chỉ nhận thưởng 1 lần/ngày.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Chưa xem hôm nay, tiến hành claim
      final success = await _videoAdRepo.recordVideoView(
        userId: authProvider.userId!,
        adId: video.adId,
        rewardAmount: video.rewardAmount,
        viewDuration: watchDuration,
        completed: completed,
      );

      if (success && mounted) {
        await walletProvider.refresh(authProvider.userId!);

        // Reload video để cập nhật views
        final updatedVideos = await _videoAdRepo.getAllActiveVideos();
        if (updatedVideos.isNotEmpty && mounted) {
          setState(() {
            _videos = updatedVideos;
            _videoClaimed[index] = true;
            _isClaimingReward[index] = false; // Reset claiming flag
          });
        }

        // KHÔNG pause video - để video tiếp tục chạy
        // Video vẫn chạy, user có thể tiếp tục xem hoặc chuyển video khác

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Nhận thưởng thành công! +${video.rewardAmount.toStringAsFixed(8)} COINZ'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Reset claiming flag if failed
        _isClaimingReward[index] = false;
      }
    } catch (e) {
      print('[VIDEO_CAROUSEL] ❌ Error claiming reward: $e');
      // Reset claiming flag on error
      _isClaimingReward[index] = false;
    }
  }

  void _changeVideo(int newIndex) {
    if (newIndex < 0 || newIndex >= _videos.length) return;
    
    print('[VIDEO_CAROUSEL] 📄 Changing video from $_currentVideoIndex to $newIndex');
    
    final oldIndex = _currentVideoIndex;
    
    // ✅ Pause video cũ (YouTube hoặc MP4)
    _pauseVideo(oldIndex);
    _stopWatchTimer();

    // Update state - Điều này sẽ trigger rebuild với key mới
    setState(() {
      _currentVideoIndex = newIndex;
    });

    print('[VIDEO_CAROUSEL] ✅ Switched to video $newIndex');
    print('[VIDEO_CAROUSEL] 🎬 Video: ${_videos[newIndex].videoTitle}');
  }
  
  /// Pause video (YouTube or MP4)
  void _pauseVideo(int index) {
    final videoType = _videoTypes[index];
    
    if (videoType == VideoType.youtube) {
      if (_youtubeControllers[index] != null) {
        _youtubeControllers[index]!.pause();
        print('[VIDEO_CAROUSEL] ⏸️ Paused YouTube video $index');
      }
    } else {
      if (_mp4Controllers[index] != null) {
        _mp4Controllers[index]!.pause();
        print('[VIDEO_CAROUSEL] ⏸️ Paused MP4 video $index');
      }
    }
  }
  
  /// Play video (YouTube or MP4)
  void _playVideo(int index) {
    final videoType = _videoTypes[index];
    
    if (videoType == VideoType.youtube) {
      if (_youtubeControllers[index] != null) {
        _youtubeControllers[index]!.play();
        print('[VIDEO_CAROUSEL] ▶️ Playing YouTube video $index');
      }
    } else {
      if (_mp4Controllers[index] != null) {
        _mp4Controllers[index]!.play();
        print('[VIDEO_CAROUSEL] ▶️ Playing MP4 video $index');
      }
    }
  }

  /// Build video player widget (YouTube or MP4)
  Widget _buildVideoPlayerWidget() {
    final videoType = _videoTypes[_currentVideoIndex];
    
    if (videoType == VideoType.youtube) {
      final controller = _youtubeControllers[_currentVideoIndex];
      if (controller == null) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return YoutubePlayer(
        key: ValueKey('youtube_$_currentVideoIndex'),
        controller: controller,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      );
    } else {
      final controller = _mp4Controllers[_currentVideoIndex];
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            // Play/Pause overlay
            GestureDetector(
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: controller.value.isPlaying
                      ? Container()  // Hide play button when playing
                      : Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            // Video progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // LUÔN hiển thị video player, không bao giờ collapse
    return _buildVideoPlayer();
  }


  Widget _buildVideoPlayer() {
    // Loading state
    if (_isLoadingVideos) {
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
              'Đang tải videos...',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text('Lỗi tải videos', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadVideosFromSupabase,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // No videos
    if (_videos.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('Không có video nào'),
        ),
      );
    }

    // ✅ Check if controller is ready (YouTube or MP4)
    final videoType = _videoTypes[_currentVideoIndex];
    final isControllerReady = videoType == VideoType.youtube
        ? _youtubeControllers[_currentVideoIndex] != null
        : (_mp4Controllers[_currentVideoIndex] != null && 
           _mp4Controllers[_currentVideoIndex]!.value.isInitialized);
    
    if (!isControllerReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentVideo = _videos[_currentVideoIndex];
    final watchTime = _watchSeconds[_currentVideoIndex] ?? 0;
    final progress = watchTime / _requiredWatchSeconds;
    final remainingSeconds = _requiredWatchSeconds - watchTime;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Video Player
          Container(
            height: 240,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // ✅ Hiển thị YouTube Player hoặc MP4 Player tùy theo video type
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildVideoPlayerWidget(),
                ),
              
              // Countdown indicator - CHỈ hiển thị khi chưa đủ 30 giây
              if (remainingSeconds > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        Text(
                          '$remainingSeconds',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

          // Info section - Nằm liền mạch bên dưới video
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Row: Reward và Views
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reward
                    Row(
                      children: [
                        Text(
                          currentVideo.rewardAmount.toStringAsFixed(3),
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.monetization_on, size: 20, color: Colors.orange),
                      ],
                    ),

                    // Divider
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.grey.shade300,
                    ),

                    // Views
                    Row(
                      children: [
                        const Icon(Icons.visibility, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${currentVideo.totalViews}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    // Claimed badge (nếu có)
                    if (_videoClaimed[_currentVideoIndex] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Đã nhận',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation section - Nằm dưới cùng card
          if (_videos.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button - Chỉ icon
                  IconButton(
                    onPressed: _currentVideoIndex > 0 
                        ? () => _changeVideo(_currentVideoIndex - 1)
                        : null,
                    icon: Icon(
                      Icons.chevron_left,
                      size: 32,
                      color: _currentVideoIndex > 0 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                    tooltip: 'Video trước',
                  ),

                  // Page indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_currentVideoIndex + 1}/${_videos.length}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  // Next button - Chỉ icon
                  IconButton(
                    onPressed: _currentVideoIndex < _videos.length - 1
                        ? () => _changeVideo(_currentVideoIndex + 1)
                        : null,
                    icon: Icon(
                      Icons.chevron_right,
                      size: 32,
                      color: _currentVideoIndex < _videos.length - 1
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                    tooltip: 'Video tiếp theo',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // ✅ Dispose all YouTube controllers
    for (final controller in _youtubeControllers.values) {
      controller.dispose();
    }
    _youtubeControllers.clear();
    
    // ✅ Dispose all MP4 controllers
    for (final controller in _mp4Controllers.values) {
      controller.dispose();
    }
    _mp4Controllers.clear();
    
    // Stop timer
    _watchTimer?.cancel();
    
    print('[VIDEO_CAROUSEL] 🗑️ Disposed all video controllers');
    super.dispose();
  }
}

