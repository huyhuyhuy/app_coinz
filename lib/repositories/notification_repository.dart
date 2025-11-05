import '../models/notification_model.dart';
import '../services/supabase_service.dart';

/// Notification Repository - Quản lý thông báo từ Supabase
class NotificationRepository {
  final _supabase = SupabaseService.client;

  /// Lấy thông báo mới nhất từ Supabase
  /// Trả về null nếu không có thông báo nào
  Future<NotificationModel?> getLatestNotification() async {
    try {
      print('[NOTIFICATION_REPO] 📢 Fetching latest notification...');

      final response = await _supabase
          .from('thong_bao')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('[NOTIFICATION_REPO] ℹ️ No notification found');
        return null;
      }

      final notification = NotificationModel.fromJson(response);
      print('[NOTIFICATION_REPO] ✅ Got latest notification: ${notification.id}');
      return notification;
    } catch (e) {
      print('[NOTIFICATION_REPO] ❌ Error fetching latest notification: $e');
      return null;
    }
  }
}

