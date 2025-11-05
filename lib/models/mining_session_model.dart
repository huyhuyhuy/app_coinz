/// Model class cho Mining Session
/// Đại diện cho một phiên đào coin
class MiningSessionModel {
  final int? id; // Local database ID
  final String sessionId; // UUID từ server
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double coinsMined;
  final double baseMiningSpeed;
  final double actualMiningSpeed;
  final double speedMultiplier;
  final bool isActive;
  final bool isValid;
  final DateTime createdAt;
  final bool syncedToServer;

  MiningSessionModel({
    this.id,
    required this.sessionId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.coinsMined = 0.0,
    this.baseMiningSpeed = 0.00000009,
    this.actualMiningSpeed = 0.0,
    this.speedMultiplier = 1.0,
    this.isActive = true,
    this.isValid = true,
    required this.createdAt,
    this.syncedToServer = false,
  });

  /// Convert từ Map (database) sang MiningSessionModel
  factory MiningSessionModel.fromMap(Map<String, dynamic> map) {
    return MiningSessionModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      userId: map['user_id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time'] as String)
          : null,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      coinsMined: (map['coins_mined'] as num?)?.toDouble() ?? 0.0,
      baseMiningSpeed: (map['base_mining_speed'] as num?)?.toDouble() ?? 0.00000009,
      actualMiningSpeed: (map['actual_mining_speed'] as num?)?.toDouble() ?? 0.0,
      speedMultiplier: (map['speed_multiplier'] as num?)?.toDouble() ?? 1.0,
      isActive: (map['is_active'] as int) == 1,
      isValid: (map['is_valid'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncedToServer: (map['synced_to_server'] as int?) == 1,
    );
  }

  /// Convert từ MiningSessionModel sang Map (database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'coins_mined': coinsMined,
      'base_mining_speed': baseMiningSpeed,
      'actual_mining_speed': actualMiningSpeed,
      'speed_multiplier': speedMultiplier,
      'is_active': isActive ? 1 : 0,
      'is_valid': isValid ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'synced_to_server': syncedToServer ? 1 : 0,
    };
  }

  /// Convert từ JSON (API) sang MiningSessionModel
  factory MiningSessionModel.fromJson(Map<String, dynamic> json) {
    return MiningSessionModel(
      sessionId: json['id'] as String,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      coinsMined: (json['coins_mined'] as num?)?.toDouble() ?? 0.0,
      baseMiningSpeed: (json['base_mining_speed'] as num?)?.toDouble() ?? 0.00000009,
      actualMiningSpeed: (json['actual_mining_speed'] as num?)?.toDouble() ?? 0.0,
      speedMultiplier: (json['speed_multiplier'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
      isValid: json['is_valid'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert từ MiningSessionModel sang JSON (API)
  Map<String, dynamic> toJson() {
    return {
      'id': sessionId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'coins_mined': coinsMined,
      'base_mining_speed': baseMiningSpeed,
      'actual_mining_speed': actualMiningSpeed,
      'speed_multiplier': speedMultiplier,
      'is_active': isActive,
      'is_valid': isValid,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with method
  MiningSessionModel copyWith({
    int? id,
    String? sessionId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    double? coinsMined,
    double? baseMiningSpeed,
    double? actualMiningSpeed,
    double? speedMultiplier,
    bool? isActive,
    bool? isValid,
    DateTime? createdAt,
    bool? syncedToServer,
  }) {
    return MiningSessionModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      coinsMined: coinsMined ?? this.coinsMined,
      baseMiningSpeed: baseMiningSpeed ?? this.baseMiningSpeed,
      actualMiningSpeed: actualMiningSpeed ?? this.actualMiningSpeed,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      isActive: isActive ?? this.isActive,
      isValid: isValid ?? this.isValid,
      createdAt: createdAt ?? this.createdAt,
      syncedToServer: syncedToServer ?? this.syncedToServer,
    );
  }

  /// Calculate duration từ start time đến hiện tại (nếu đang active)
  int get currentDuration {
    if (endTime != null) return durationSeconds;
    return DateTime.now().difference(startTime).inSeconds;
  }

  /// Calculate coins mined đến hiện tại
  double get currentCoinsMined {
    if (endTime != null) return coinsMined;
    return actualMiningSpeed * currentDuration;
  }

  /// Format duration thành HH:MM:SS
  String get formattedDuration {
    int seconds = currentDuration;
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format coins mined
  String get formattedCoinsMined => currentCoinsMined.toStringAsFixed(8);

  /// Format mining speed
  String get formattedMiningSpeed => actualMiningSpeed.toStringAsFixed(8);

  @override
  String toString() {
    return 'MiningSessionModel(sessionId: $sessionId, userId: $userId, coinsMined: $coinsMined, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiningSessionModel && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}

