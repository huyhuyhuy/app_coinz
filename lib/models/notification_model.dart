/// Model class cho Notification (Thông báo)
/// Đại diện cho thông báo cho toàn thể người dùng
class NotificationModel {
  final String id; // UUID từ server
  final String noiDung; // Nội dung thông báo
  final DateTime createdAt; // Thời gian tạo

  NotificationModel({
    required this.id,
    required this.noiDung,
    required this.createdAt,
  });

  /// Convert từ JSON (API) sang NotificationModel
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      noiDung: json['noi_dung'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert từ NotificationModel sang JSON (API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noi_dung': noiDung,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, noiDung: ${noiDung.substring(0, noiDung.length > 50 ? 50 : noiDung.length)}..., createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

