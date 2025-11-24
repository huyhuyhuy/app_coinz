/// Transaction Model - Giao dịch coin
class TransactionModel {
  final int? id; // Local database ID
  final String transactionId; // Server UUID
  final String userId; // User liên quan đến giao dịch này
  final String transactionType; // 'mining', 'referral', 'transfer_send', 'transfer_receive', 'withdrawal'
  final double amount;
  final double feeAmount;
  final double netAmount;
  final double balanceBefore;
  final double balanceAfter;
  final String? fromUserId;
  final String? toUserId;
  final String? externalWalletAddress;
  final String description;
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncedToServer;

  TransactionModel({
    this.id,
    required this.transactionId,
    required this.userId,
    required this.transactionType,
    required this.amount,
    this.feeAmount = 0.0,
    required this.netAmount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.fromUserId,
    this.toUserId,
    this.externalWalletAddress,
    this.description = '',
    this.status = 'completed',
    required this.createdAt,
    required this.updatedAt,
    this.syncedToServer = false,
  });

  /// Convert từ Map (local database) sang TransactionModel
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as String,
      userId: map['user_id'] as String,
      transactionType: map['transaction_type'] as String,
      amount: (map['amount'] as num).toDouble(),
      feeAmount: (map['fee_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (map['net_amount'] as num).toDouble(),
      balanceBefore: (map['balance_before'] as num).toDouble(),
      balanceAfter: (map['balance_after'] as num).toDouble(),
      fromUserId: map['from_user_id'] as String?,
      toUserId: map['to_user_id'] as String?,
      externalWalletAddress: map['external_wallet_address'] as String?,
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedToServer: (map['synced_to_server'] as int?) == 1,
    );
  }

  /// Convert sang Map (local database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'transaction_id': transactionId,
      'user_id': userId,
      'transaction_type': transactionType,
      'amount': amount,
      'fee_amount': feeAmount,
      'net_amount': netAmount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (toUserId != null) 'to_user_id': toUserId,
      if (externalWalletAddress != null) 'external_wallet_address': externalWalletAddress,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_to_server': syncedToServer ? 1 : 0,
    };
  }

  /// Convert từ JSON (server) sang TransactionModel
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['id'] as String,
      userId: json['user_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      fromUserId: json['from_user_id'] as String?,
      toUserId: json['to_user_id'] as String?,
      externalWalletAddress: json['external_wallet_address'] as String?,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncedToServer: true,
    );
  }

  /// Convert sang JSON (server)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'transaction_type': transactionType,
      'amount': amount,
      'fee_amount': feeAmount,
      'net_amount': netAmount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (toUserId != null) 'to_user_id': toUserId,
      if (externalWalletAddress != null) 'external_wallet_address': externalWalletAddress,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  TransactionModel copyWith({
    int? id,
    String? transactionId,
    String? userId,
    String? transactionType,
    double? amount,
    double? feeAmount,
    double? netAmount,
    double? balanceBefore,
    double? balanceAfter,
    String? fromUserId,
    String? toUserId,
    String? externalWalletAddress,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncedToServer,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      feeAmount: feeAmount ?? this.feeAmount,
      netAmount: netAmount ?? this.netAmount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      externalWalletAddress: externalWalletAddress ?? this.externalWalletAddress,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedToServer: syncedToServer ?? this.syncedToServer,
    );
  }

  /// Format display
  String get formattedAmount => amount.toStringAsFixed(8);
  String get typeDisplay {
    switch (transactionType) {
      case 'mining':
        return 'Earning Reward';
      case 'referral':
        return 'Referral Bonus';
      case 'transfer_send':
        return 'Points Sent';
      case 'transfer_receive':
        return 'Points Received';
      case 'withdrawal':
        return 'Withdrawal';
      default:
        return transactionType;
    }
  }

  @override
  String toString() {
    return 'TransactionModel(type: $transactionType, amount: $amount, status: $status)';
  }
}

