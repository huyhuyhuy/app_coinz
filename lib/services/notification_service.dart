import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

/// Notification Service - Quản lý việc check và hiển thị thông báo
/// Mỗi thông báo chỉ hiển thị 1 lần duy nhất cho mỗi người dùng
class NotificationService {
  static const String _lastNotificationIdKey = 'last_notification_id';
  final NotificationRepository _notificationRepo = NotificationRepository();

  /// Check và lấy thông báo mới nếu có
  /// Trả về NotificationModel nếu có thông báo mới (ID khác với ID đã lưu)
  /// Trả về null nếu không có thông báo mới hoặc đã xem rồi
  Future<NotificationModel?> checkForNewNotification() async {
    try {
      print('[NOTIFICATION_SERVICE] 🔍 Checking for new notification...');

      // 1. Fetch thông báo mới nhất từ Supabase
      final latestNotification = await _notificationRepo.getLatestNotification();
      
      if (latestNotification == null) {
        print('[NOTIFICATION_SERVICE] ℹ️ No notification found');
        return null;
      }

      // 2. Lấy ID thông báo đã xem từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastViewedId = prefs.getString(_lastNotificationIdKey);

      print('[NOTIFICATION_SERVICE] 📋 Last viewed ID: $lastViewedId');
      print('[NOTIFICATION_SERVICE] 📋 Latest notification ID: ${latestNotification.id}');

      // 3. So sánh ID
      if (lastViewedId == latestNotification.id) {
        print('[NOTIFICATION_SERVICE] ✅ Notification already viewed');
        return null;
      }

      // 4. Có thông báo mới
      print('[NOTIFICATION_SERVICE] ✅ New notification found!');
      return latestNotification;
    } catch (e) {
      print('[NOTIFICATION_SERVICE] ❌ Error checking notification: $e');
      return null;
    }
  }

  /// Lưu ID thông báo đã xem vào SharedPreferences
  /// Gọi khi user đóng thông báo (nhấn X)
  Future<void> markNotificationAsViewed(String notificationId) async {
    try {
      print('[NOTIFICATION_SERVICE] 💾 Saving notification ID: $notificationId');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastNotificationIdKey, notificationId);
      
      print('[NOTIFICATION_SERVICE] ✅ Notification ID saved');
    } catch (e) {
      print('[NOTIFICATION_SERVICE] ❌ Error saving notification ID: $e');
    }
  }

  /// Reset notification ID (dùng cho testing hoặc khi cần hiển thị lại)
  Future<void> resetNotificationId() async {
    try {
      print('[NOTIFICATION_SERVICE] 🔄 Resetting notification ID...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastNotificationIdKey);
      
      print('[NOTIFICATION_SERVICE] ✅ Notification ID reset');
    } catch (e) {
      print('[NOTIFICATION_SERVICE] ❌ Error resetting notification ID: $e');
    }
  }
}

