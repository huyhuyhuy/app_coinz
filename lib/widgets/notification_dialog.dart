import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notification Dialog Widget
/// Hiển thị thông báo cho toàn thể người dùng
/// UI đơn giản nhưng hiện đại, hiển thị ở giữa màn hình
class NotificationDialog extends StatelessWidget {
  final NotificationModel notification;
  final NotificationService notificationService;

  const NotificationDialog({
    super.key,
    required this.notification,
    required this.notificationService,
  });

  /// Hiển thị dialog thông báo
  static Future<void> show(
    BuildContext context,
    NotificationModel notification,
    NotificationService notificationService,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Không đóng khi tap ra ngoài
      builder: (dialogContext) => NotificationDialog(
        notification: notification,
        notificationService: notificationService,
      ),
    );
  }

  /// Xử lý khi nhấn nút X (đóng)
  void _handleClose(BuildContext context) async {
    // Lưu ID thông báo đã xem
    await notificationService.markNotificationAsViewed(notification.id);
    
    // Đóng dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tỉ lệ của background_noti.png (512x341px)
    const double aspectRatio = 512.0 / 341.0; // ≈ 1.501
    
    // Lấy kích thước màn hình
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Tính toán kích thước dialog để vừa khớp màn hình
    // Giữ margin 32px mỗi bên (tổng 64px)
    final maxWidth = screenWidth - 64;
    final maxHeight = screenHeight - 64;
    
    // Tính width và height dựa trên tỉ lệ, không vượt quá màn hình
    double dialogWidth = maxWidth;
    double dialogHeight = dialogWidth / aspectRatio;
    
    // Nếu height quá lớn, điều chỉnh lại
    if (dialogHeight > maxHeight) {
      dialogHeight = maxHeight;
      dialogWidth = dialogHeight * aspectRatio;
    }
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Stack(
            children: [
              // Layer 1: Background background_noti.png - hiển thị nguyên, không làm mờ
              Positioned.fill(
                child: Image.asset(
                  'assets/icons/background_noti.png',
                  width: dialogWidth,
                  height: dialogHeight,
                  fit: BoxFit.cover, // Cover để phủ kín toàn bộ dialog
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback nếu không load được ảnh
                    return Container(
                      width: dialogWidth,
                      height: dialogHeight,
                      color: Colors.grey.shade100,
                    );
                  },
                ),
              ),
              
              // Layer 2: Nội dung thông báo - căn giữa, chữ trắng in đậm có viền đen
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Text(
                    notification.noiDung,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w700, // W700 để sắc nét hơn
                      color: Colors.white, // Chữ màu trắng
                      letterSpacing: 0.2, // Tăng khoảng cách chữ để sắc nét hơn
                      shadows: [
                        // Viền đen mỏng hơn (giảm từ 1.5 xuống 0.8)
                        const Shadow(
                          offset: Offset(-0.8, -0.8),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        const Shadow(
                          offset: Offset(0.8, -0.8),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        const Shadow(
                          offset: Offset(0.8, 0.8),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        const Shadow(
                          offset: Offset(-0.8, 0.8),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        // Viền đen ở giữa các góc
                        const Shadow(
                          offset: Offset(-0.8, 0),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        const Shadow(
                          offset: Offset(0.8, 0),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        const Shadow(
                          offset: Offset(0, -0.8),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                        const Shadow(
                          offset: Offset(0, 0.8),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center, // Căn giữa
                  ),
                ),
              ),
              
              // Layer 4: Dấu X ở góc phải trên với background tròn đen trong suốt
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleClose(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4), // Đen trong suốt
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

