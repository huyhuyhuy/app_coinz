import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';

/// Mining Provider - Quản lý mining engine với real-time updates
class MiningProvider with ChangeNotifier {
  final MiningRepository _miningRepo = MiningRepository();
  
  // Mining state
  bool _isMining = false;
  MiningSessionModel? _currentSession;
  double _currentCoins = 0.0;
  int _currentDuration = 0;
  double _miningSpeed = 0.001; // coins per second
  double _speedMultiplier = 1.0;
  
  // Timer
  Timer? _miningTimer;
  
  // Getters
  bool get isMining => _isMining;
  MiningSessionModel? get currentSession => _currentSession;
  double get currentCoins => _currentCoins;
  int get currentDuration => _currentDuration;
  double get miningSpeed => _miningSpeed;
  double get speedMultiplier => _speedMultiplier;
  
  // Formatted getters
  String get formattedCoins => _currentCoins.toStringAsFixed(8);
  String get formattedDuration {
    int hours = _currentDuration ~/ 3600;
    int minutes = (_currentDuration % 3600) ~/ 60;
    int seconds = _currentDuration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  String get formattedSpeed => _miningSpeed.toStringAsFixed(6);
  
  /// Initialize mining provider
  Future<void> initialize(String userId) async {
    try {
      print('[MINING_PROVIDER] 🚀 Initializing mining provider...');
      
      // Check if there's an active mining session
      final progress = await _miningRepo.getMiningProgress(userId);
      if (progress != null) {
        _currentSession = progress['session'];
        _currentCoins = progress['coinsMined'];
        _currentDuration = progress['duration'];
        _miningSpeed = progress['miningSpeed'];
        _speedMultiplier = _currentSession?.speedMultiplier ?? 1.0;
        _isMining = true;
        
        // Resume mining timer
        _startMiningTimer();
        
        print('[MINING_PROVIDER] ✅ Resumed active mining session');
      } else {
        print('[MINING_PROVIDER] ℹ️ No active mining session');
      }
      
      notifyListeners();
    } catch (e) {
      print('[MINING_PROVIDER] ❌ Error initializing: $e');
    }
  }
  
  /// Start mining
  Future<bool> startMining(String userId) async {
    try {
      if (_isMining) {
        print('[MINING_PROVIDER] ⚠️ Mining already active');
        return false;
      }
      
      print('[MINING_PROVIDER] ⛏️ Starting mining...');
      
      // Start mining session
      final session = await _miningRepo.startMining(
        userId,
        speedMultiplier: _speedMultiplier,
      );
      
      if (session == null) {
        print('[MINING_PROVIDER] ❌ Failed to start mining');
        return false;
      }
      
      _currentSession = session;
      _currentCoins = 0.0;
      _currentDuration = 0;
      _miningSpeed = session.actualMiningSpeed;
      _isMining = true;
      
      // Start timer
      _startMiningTimer();
      
      notifyListeners();
      print('[MINING_PROVIDER] ✅ Mining started');
      return true;
    } catch (e) {
      print('[MINING_PROVIDER] ❌ Error starting mining: $e');
      return false;
    }
  }
  
  /// Stop mining
  Future<bool> stopMining(String userId) async {
    try {
      if (!_isMining) {
        print('[MINING_PROVIDER] ⚠️ Mining not active');
        return false;
      }
      
      print('[MINING_PROVIDER] 🛑 Stopping mining...');
      
      // Stop timer
      _stopMiningTimer();
      
      // Stop mining session
      final session = await _miningRepo.stopMining(userId);
      
      if (session == null) {
        print('[MINING_PROVIDER] ❌ Failed to stop mining');
        return false;
      }
      
      _currentSession = session;
      _currentCoins = session.coinsMined;
      _currentDuration = session.durationSeconds;
      _isMining = false;
      
      notifyListeners();
      print('[MINING_PROVIDER] ✅ Mining stopped. Total coins: ${session.coinsMined}');
      return true;
    } catch (e) {
      print('[MINING_PROVIDER] ❌ Error stopping mining: $e');
      return false;
    }
  }
  
  /// Set speed multiplier (from watching videos)
  void setSpeedMultiplier(double multiplier) {
    _speedMultiplier = multiplier;
    if (_isMining && _currentSession != null) {
      _miningSpeed = 0.001 * _speedMultiplier;
    }
    notifyListeners();
    print('[MINING_PROVIDER] ⚡ Speed multiplier set to: $multiplier');
  }
  
  /// Start mining timer (updates every second)
  void _startMiningTimer() {
    _miningTimer?.cancel();
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMining && _currentSession != null) {
        _currentDuration++;
        _currentCoins = _miningSpeed * _currentDuration;
        notifyListeners();
      }
    });
    print('[MINING_PROVIDER] ⏱️ Mining timer started');
  }
  
  /// Stop mining timer
  void _stopMiningTimer() {
    _miningTimer?.cancel();
    _miningTimer = null;
    print('[MINING_PROVIDER] ⏱️ Mining timer stopped');
  }
  
  /// Get mining statistics
  Future<Map<String, dynamic>> getMiningStats(String userId) async {
    try {
      final totalCoins = await _miningRepo.getTotalCoinsMined(userId);
      final totalTime = await _miningRepo.getTotalMiningTime(userId);
      final sessions = await _miningRepo.getMiningSessionsForUser(userId);
      
      return {
        'totalCoins': totalCoins,
        'totalTime': totalTime,
        'totalSessions': sessions.length,
        'averageCoinsPerSession': sessions.isNotEmpty ? totalCoins / sessions.length : 0,
        'averageTimePerSession': sessions.isNotEmpty ? totalTime / sessions.length : 0,
      };
    } catch (e) {
      print('[MINING_PROVIDER] ❌ Error getting mining stats: $e');
      return {};
    }
  }
  
  @override
  void dispose() {
    _stopMiningTimer();
    super.dispose();
  }
}

