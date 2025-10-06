/// Model class cho Wallet
/// Đại diện cho ví coin của người dùng
class WalletModel {
  final int? id; // Local database ID
  final String userId;
  final String walletAddress;
  final double balance;
  final double pendingBalance;
  final double totalEarned;
  final double totalSpent;
  final double totalWithdrawn;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncedToServer;

  WalletModel({
    this.id,
    required this.userId,
    required this.walletAddress,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
    this.totalWithdrawn = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.syncedToServer = false,
  });

  /// Convert từ Map (database) sang WalletModel
  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      walletAddress: map['wallet_address'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (map['pending_balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (map['total_earned'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (map['total_withdrawn'] as num?)?.toDouble() ?? 0.0,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedToServer: (map['synced_to_server'] as int?) == 1,
    );
  }

  /// Convert từ WalletModel sang Map (database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'wallet_address': walletAddress,
      'balance': balance,
      'pending_balance': pendingBalance,
      'total_earned': totalEarned,
      'total_spent': totalSpent,
      'total_withdrawn': totalWithdrawn,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_to_server': syncedToServer ? 1 : 0,
    };
  }

  /// Convert từ JSON (API) sang WalletModel
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['user_id'] as String,
      walletAddress: json['wallet_address'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pending_balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['total_withdrawn'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert từ WalletModel sang JSON (API)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wallet_address': walletAddress,
      'balance': balance,
      'pending_balance': pendingBalance,
      'total_earned': totalEarned,
      'total_spent': totalSpent,
      'total_withdrawn': totalWithdrawn,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method
  WalletModel copyWith({
    int? id,
    String? userId,
    String? walletAddress,
    double? balance,
    double? pendingBalance,
    double? totalEarned,
    double? totalSpent,
    double? totalWithdrawn,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncedToServer,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletAddress: walletAddress ?? this.walletAddress,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedToServer: syncedToServer ?? this.syncedToServer,
    );
  }

  /// Get total balance (balance + pending)
  double get totalBalance => balance + pendingBalance;

  /// Get available balance for withdrawal
  double get availableBalance => balance;

  /// Format balance với số thập phân
  String get formattedBalance => balance.toStringAsFixed(8);

  /// Format balance ngắn gọn (2 số thập phân)
  String get formattedBalanceShort => balance.toStringAsFixed(2);

  /// Shortened wallet address (first 6 + ... + last 4)
  String get shortWalletAddress {
    if (walletAddress.length <= 10) return walletAddress;
    return '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}';
  }

  @override
  String toString() {
    return 'WalletModel(userId: $userId, walletAddress: $walletAddress, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletModel && other.walletAddress == walletAddress;
  }

  @override
  int get hashCode => walletAddress.hashCode;
}

