/// Model cho Video Ads
class VideoAdModel {
  final String adId;
  final String contractCode;
  final String videoUrl;
  final String? videoTitle;
  final String? videoDescription;
  final double rewardAmount;
  final String status; // 'active', 'inactive', 'expired'
  final int totalViews;
  final int? maxViews;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoAdModel({
    required this.adId,
    required this.contractCode,
    required this.videoUrl,
    this.videoTitle,
    this.videoDescription,
    required this.rewardAmount,
    required this.status,
    required this.totalViews,
    this.maxViews,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo từ JSON (từ Supabase)
  factory VideoAdModel.fromJson(Map<String, dynamic> json) {
    try {
      print('[VIDEO_AD_MODEL] 📦 Parsing JSON: $json');

      return VideoAdModel(
        adId: json['ad_id']?.toString() ?? '',
        contractCode: json['contract_code']?.toString() ?? '',
        videoUrl: json['video_url']?.toString() ?? '',
        videoTitle: json['video_title']?.toString(),
        videoDescription: json['video_description']?.toString(),
        rewardAmount: (json['reward_amount'] as num?)?.toDouble() ?? 0.0,
        status: json['status']?.toString() ?? 'inactive',
        totalViews: json['total_views'] as int? ?? 0,
        maxViews: json['max_views'] as int?,
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'].toString())
            : null,
        endDate: json['end_date'] != null
            ? DateTime.tryParse(json['end_date'].toString())
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print('[VIDEO_AD_MODEL] ❌ Error parsing JSON: $e');
      print('[VIDEO_AD_MODEL] 📋 JSON data: $json');
      rethrow;
    }
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'ad_id': adId,
      'contract_code': contractCode,
      'video_url': videoUrl,
      'video_title': videoTitle,
      'video_description': videoDescription,
      'reward_amount': rewardAmount,
      'status': status,
      'total_views': totalViews,
      'max_views': maxViews,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check xem video còn available không
  bool get isAvailable {
    if (status != 'active') return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    if (maxViews != null && totalViews >= maxViews!) return false;
    return true;
  }

  /// Format reward amount
  String get formattedReward => rewardAmount.toStringAsFixed(3);

  /// Copy with
  VideoAdModel copyWith({
    String? adId,
    String? contractCode,
    String? videoUrl,
    String? videoTitle,
    String? videoDescription,
    double? rewardAmount,
    String? status,
    int? totalViews,
    int? maxViews,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoAdModel(
      adId: adId ?? this.adId,
      contractCode: contractCode ?? this.contractCode,
      videoUrl: videoUrl ?? this.videoUrl,
      videoTitle: videoTitle ?? this.videoTitle,
      videoDescription: videoDescription ?? this.videoDescription,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      status: status ?? this.status,
      totalViews: totalViews ?? this.totalViews,
      maxViews: maxViews ?? this.maxViews,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model cho Video View (lịch sử xem)
class VideoViewModel {
  final String viewId;
  final String userId;
  final String adId;
  final double rewardEarned;
  final int viewDuration; // seconds
  final bool completed;
  final DateTime viewedAt;

  VideoViewModel({
    required this.viewId,
    required this.userId,
    required this.adId,
    required this.rewardEarned,
    required this.viewDuration,
    required this.completed,
    required this.viewedAt,
  });

  /// Tạo từ JSON
  factory VideoViewModel.fromJson(Map<String, dynamic> json) {
    return VideoViewModel(
      viewId: json['view_id'] as String,
      userId: json['user_id'] as String,
      adId: json['ad_id'] as String,
      rewardEarned: (json['reward_earned'] as num).toDouble(),
      viewDuration: json['view_duration'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'view_id': viewId,
      'user_id': userId,
      'ad_id': adId,
      'reward_earned': rewardEarned,
      'view_duration': viewDuration,
      'completed': completed,
      'viewed_at': viewedAt.toIso8601String(),
    };
  }

  /// Format reward
  String get formattedReward => rewardEarned.toStringAsFixed(3);

  /// Format duration
  String get formattedDuration {
    final minutes = viewDuration ~/ 60;
    final seconds = viewDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

