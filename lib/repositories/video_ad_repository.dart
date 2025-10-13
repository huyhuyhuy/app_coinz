import '../models/video_ad_model.dart';
import '../services/supabase_service.dart';
import '../repositories/wallet_repository.dart';

/// Repository để quản lý Video Ads
class VideoAdRepository {
  final _supabase = SupabaseService.client;
  final _walletRepo = WalletRepository();

  /// Lấy video active ngẫu nhiên từ server
  Future<VideoAdModel?> getRandomActiveVideo() async {
    try {
      print('[VIDEO_AD_REPO] 🎬 Getting random active video...');

      // Query trực tiếp từ table để đảm bảo lấy đầy đủ thông tin bao gồm total_views
      final response = await _supabase
          .from('video_ads')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1);

      if (response == null || (response as List).isEmpty) {
        print('[VIDEO_AD_REPO] ℹ️ No active video found');
        return null;
      }

      final videoData = (response as List).first as Map<String, dynamic>;
      final video = VideoAdModel.fromJson(videoData);
      print('[VIDEO_AD_REPO] ✅ Got video: ${video.videoTitle}');
      print('[VIDEO_AD_REPO] 👁️ Total views from DB: ${video.totalViews}');
      return video;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error getting random video: $e');
      print('[VIDEO_AD_REPO] 📋 Error details: $e');
      return null;
    }
  }

  /// Lấy tất cả video active
  Future<List<VideoAdModel>> getAllActiveVideos() async {
    try {
      print('[VIDEO_AD_REPO] 🎬 Getting all active videos...');

      final response = await _supabase
          .from('video_ads')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final videos = (response as List)
          .map((json) => VideoAdModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('[VIDEO_AD_REPO] ✅ Got ${videos.length} active videos');
      return videos;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error getting active videos: $e');
      return [];
    }
  }

  /// Lưu lịch sử xem video và cộng reward
  Future<bool> recordVideoView({
    required String userId,
    required String adId,
    required double rewardAmount,
    required int viewDuration,
    required bool completed,
  }) async {
    try {
      print('[VIDEO_AD_REPO] 📹 Recording video view...');

      // 1. Tạo view record
      final viewData = {
        'user_id': userId,
        'ad_id': adId,
        'reward_earned': rewardAmount,
        'view_duration': viewDuration,
        'completed': completed,
        'viewed_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('video_views').insert(viewData);
      print('[VIDEO_AD_REPO] ✅ Video view recorded');
      print('[VIDEO_AD_REPO] ℹ️ Database trigger will auto-increment total_views');

      // 2. Nếu xem xong, cộng reward vào wallet
      if (completed && rewardAmount > 0) {
        await _walletRepo.addCoins(userId, rewardAmount);
        print('[VIDEO_AD_REPO] ✅ Reward added to wallet: $rewardAmount COINZ');
      }

      return true;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error recording video view: $e');
      return false;
    }
  }

  /// Lấy lịch sử xem video của user
  Future<List<VideoViewModel>> getUserVideoHistory(String userId, {int limit = 50}) async {
    try {
      print('[VIDEO_AD_REPO] 📜 Getting user video history...');

      final response = await _supabase
          .from('video_views')
          .select()
          .eq('user_id', userId)
          .order('viewed_at', ascending: false)
          .limit(limit);

      final views = (response as List)
          .map((json) => VideoViewModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('[VIDEO_AD_REPO] ✅ Got ${views.length} video views');
      return views;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error getting video history: $e');
      return [];
    }
  }

  /// Lấy tổng số video đã xem của user
  Future<int> getUserTotalViews(String userId) async {
    try {
      final response = await _supabase
          .from('video_views')
          .select('view_id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error getting total views: $e');
      return 0;
    }
  }

  /// Lấy tổng reward đã kiếm được từ video
  Future<double> getUserTotalRewards(String userId) async {
    try {
      final response = await _supabase
          .from('video_views')
          .select('reward_earned')
          .eq('user_id', userId)
          .eq('completed', true);

      double total = 0;
      for (var view in response as List) {
        total += (view['reward_earned'] as num).toDouble();
      }

      return total;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error getting total rewards: $e');
      return 0;
    }
  }

  /// Check xem user đã xem video này chưa (trong 24h)
  Future<bool> hasUserViewedRecently(String userId, String adId) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));

      final response = await _supabase
          .from('video_views')
          .select('view_id')
          .eq('user_id', userId)
          .eq('ad_id', adId)
          .gte('viewed_at', yesterday.toIso8601String())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('[VIDEO_AD_REPO] ❌ Error checking recent view: $e');
      return false;
    }
  }
}

