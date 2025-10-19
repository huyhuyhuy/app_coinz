import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Storage Service - Quản lý upload/delete files trên Supabase Storage
class StorageService {
  static const String _avatarBucket = 'avatars';

  /// Upload avatar cho user
  /// Returns: Public URL của ảnh đã upload
  static Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('[STORAGE_SERVICE] 📤 Uploading avatar for user: $userId');

      final fileName = 'avatar.jpg'; // Tên file cố định, sẽ overwrite ảnh cũ
      final filePath = '$userId/$fileName'; // Path: {user_id}/avatar.jpg

      print('[STORAGE_SERVICE] 📁 File path: $filePath');

      // Đọc bytes từ file
      final bytes = await imageFile.readAsBytes();
      print('[STORAGE_SERVICE] 📊 File size: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(2)} KB)');

      // Upload lên Supabase Storage
      await SupabaseService.client.storage
          .from(_avatarBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Overwrite nếu file đã tồn tại
              contentType: 'image/jpeg',
            ),
          );

      print('[STORAGE_SERVICE] ✅ Avatar uploaded successfully');

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(_avatarBucket)
          .getPublicUrl(filePath);

      print('[STORAGE_SERVICE] 🌐 Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('[STORAGE_SERVICE] ❌ Error uploading avatar: $e');
      return null;
    }
  }

  /// Delete avatar của user
  static Future<bool> deleteAvatar({required String userId}) async {
    try {
      print('[STORAGE_SERVICE] 🗑️ Deleting avatar for user: $userId');

      final fileName = 'avatar.jpg';
      final filePath = '$userId/$fileName';

      await SupabaseService.client.storage
          .from(_avatarBucket)
          .remove([filePath]);

      print('[STORAGE_SERVICE] ✅ Avatar deleted successfully');
      return true;
    } catch (e) {
      print('[STORAGE_SERVICE] ❌ Error deleting avatar: $e');
      return false;
    }
  }

  /// Get avatar URL của user
  static String? getAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }
    
    // Nếu đã là URL đầy đủ, return luôn
    if (avatarUrl.startsWith('http')) {
      return avatarUrl;
    }
    
    // Nếu là path, tạo public URL
    return SupabaseService.client.storage
        .from(_avatarBucket)
        .getPublicUrl(avatarUrl);
  }

  /// Check xem user đã có avatar chưa
  static Future<bool> hasAvatar({required String userId}) async {
    try {
      final fileName = 'avatar.jpg';
      final filePath = '$userId/$fileName';

      final files = await SupabaseService.client.storage
          .from(_avatarBucket)
          .list(path: userId);

      return files.any((file) => file.name == fileName);
    } catch (e) {
      print('[STORAGE_SERVICE] ❌ Error checking avatar: $e');
      return false;
    }
  }

  /// Validate image file
  static String? validateImageFile(File file) {
    // Check file exists
    if (!file.existsSync()) {
      return 'File does not exist';
    }

    // Check file size (max 5MB)
    final fileSize = file.lengthSync();
    const maxSize = 5 * 1024 * 1024; // 5MB
    
    if (fileSize > maxSize) {
      return 'File size too large. Max 5MB allowed.';
    }

    if (fileSize == 0) {
      return 'File is empty';
    }

    return null; // Valid
  }
}

