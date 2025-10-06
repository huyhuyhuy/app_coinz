/// Model class cho User
/// Đại diện cho thông tin người dùng trong app
class UserModel {
  final int? id; // Local database ID
  final String userId; // UUID từ server
  final String email;
  final String passwordHash;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;
  final String referralCode;
  final String? referredBy;
  final int totalReferrals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  UserModel({
    this.id,
    required this.userId,
    required this.email,
    required this.passwordHash,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.referralCode,
    this.referredBy,
    this.totalReferrals = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  /// Convert từ Map (database) sang UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      isVerified: (map['is_verified'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      referralCode: map['referral_code'] as String,
      referredBy: map['referred_by'] as String?,
      totalReferrals: map['total_referrals'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastLogin: map['last_login'] != null 
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }

  /// Convert từ UserModel sang Map (database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'is_verified': isVerified ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'total_referrals': totalReferrals,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Convert từ JSON (API) sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String? ?? '',
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      referralCode: json['referral_code'] as String,
      referredBy: json['referred_by'] as String?,
      totalReferrals: json['total_referrals'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  /// Convert từ UserModel sang JSON (API)
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'total_referrals': totalReferrals,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Copy with method để tạo instance mới với một số field thay đổi
  UserModel copyWith({
    int? id,
    String? userId,
    String? email,
    String? passwordHash,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    bool? isVerified,
    bool? isActive,
    String? referralCode,
    String? referredBy,
    int? totalReferrals,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  /// Get initials từ full name (để hiển thị avatar)
  String get initials {
    List<String> names = fullName.trim().split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  /// Get first name
  String get firstName {
    List<String> names = fullName.trim().split(' ');
    return names.isNotEmpty ? names[0] : fullName;
  }

  /// Get last name
  String get lastName {
    List<String> names = fullName.trim().split(' ');
    return names.length > 1 ? names[names.length - 1] : '';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, userId: $userId, email: $email, fullName: $fullName, referralCode: $referralCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

