import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Manager cho App Open Ads
/// - Show 1 lần mỗi 4 giờ
/// - Smart loading: skip nếu không ready
/// - Timeout 5 giây khi load
class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
  static bool _isAdLoaded = false;
  
  // ✅ Production Ad Unit ID cho App Open Ads
  static String get appOpenAdUnitId {
    // Production ad unit ID
    return 'ca-app-pub-4969810842586372/8233130697';
  }
  
  // ✅ Frequency: 4 giờ
  static const Duration _minTimeBetweenAds = Duration(hours: 4);
  static const String _lastShownTimeKey = 'app_open_ad_last_shown';
  
  // ✅ Timeout cho ad loading - tăng lên 8s vì main thread có thể bận
  static const Duration _loadTimeout = Duration(seconds: 8);
  
  /// ✅ Load ad và đợi thực sự cho đến khi load xong (hoặc timeout)
  static Future<void> loadAd() async {
    // Không load trên web
    if (kIsWeb) {
      print('[APP_OPEN_AD] 🌐 Web platform - skip loading');
      return;
    }
    
    // Check xem đã đủ 4 giờ chưa
    final canShow = await _canShowAd();
    if (!canShow) {
      print('[APP_OPEN_AD] ⏰ Chưa đủ 4 giờ - skip loading');
      return;
    }
    
    print('[APP_OPEN_AD] 📱 Loading app open ad...');
    
    // ✅ Dùng Completer để đợi callback
    final completer = Completer<void>();
    
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('[APP_OPEN_AD] ✅ Ad loaded successfully');
          _appOpenAd = ad;
          _isAdLoaded = true;
          
          // ✅ Complete future khi ad load xong
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onAdFailedToLoad: (error) {
          print('[APP_OPEN_AD] ❌ Failed to load: $error');
          _isAdLoaded = false;
          _appOpenAd = null;
          
          // ✅ Complete future ngay cả khi fail
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
    
    // ✅ Đợi ad load xong HOẶC timeout sau 5 giây
    try {
      await completer.future.timeout(
        _loadTimeout,
        onTimeout: () {
          print('[APP_OPEN_AD] ⏱️ Load timeout after ${_loadTimeout.inSeconds}s - continue anyway');
        },
      );
    } catch (e) {
      print('[APP_OPEN_AD] ⚠️ Load error: $e');
    }
    
    // Log kết quả
    if (_isAdLoaded) {
      print('[APP_OPEN_AD] ✅ Ad ready to show');
    } else {
      print('[APP_OPEN_AD] ⚠️ Ad not loaded - will skip');
    }
  }
  
  /// ✅ Show ad (nếu ready)
  static Future<void> showAdIfReady({required VoidCallback onAdDismissed}) async {
    // Không show trên web
    if (kIsWeb) {
      onAdDismissed();
      return;
    }
    
    // Check đã load chưa
    if (!_isAdLoaded || _appOpenAd == null) {
      print('[APP_OPEN_AD] ⚠️ Ad not ready - skip');
      onAdDismissed();
      return;
    }
    
    // Check đang show không
    if (_isShowingAd) {
      print('[APP_OPEN_AD] ⚠️ Already showing ad - skip');
      return;
    }
    
    // Check đã đủ 4 giờ chưa (double check)
    final canShow = await _canShowAd();
    if (!canShow) {
      print('[APP_OPEN_AD] ⏰ Chưa đủ 4 giờ - skip');
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _isAdLoaded = false;
      onAdDismissed();
      return;
    }
    
    print('[APP_OPEN_AD] 🎬 Showing app open ad...');
    _isShowingAd = true;
    
    // Setup callbacks
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('[APP_OPEN_AD] 📺 Ad showed full screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('[APP_OPEN_AD] ✅ Ad dismissed');
        _isShowingAd = false;
        _isAdLoaded = false;
        ad.dispose();
        _appOpenAd = null;
        
        // ✅ Save last shown time
        _saveLastShownTime();
        
        // Callback để continue app
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('[APP_OPEN_AD] ❌ Failed to show: $error');
        _isShowingAd = false;
        _isAdLoaded = false;
        ad.dispose();
        _appOpenAd = null;
        
        // Continue app nếu fail
        onAdDismissed();
      },
    );
    
    // Show ad
    await _appOpenAd!.show();
  }
  
  /// ✅ Check xem có thể show ad không (đã qua 4 giờ)
  static Future<bool> _canShowAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShownTimestamp = prefs.getInt(_lastShownTimeKey);
      
      if (lastShownTimestamp == null) {
        // Chưa show lần nào → OK
        print('[APP_OPEN_AD] 🆕 Chưa show lần nào - OK');
        return true;
      }
      
      final lastShownTime = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
      final now = DateTime.now();
      final timeSinceLastAd = now.difference(lastShownTime);
      
      final canShow = timeSinceLastAd >= _minTimeBetweenAds;
      
      if (canShow) {
        print('[APP_OPEN_AD] ✅ Đã qua ${timeSinceLastAd.inHours} giờ - OK');
      } else {
        final remainingTime = _minTimeBetweenAds - timeSinceLastAd;
        print('[APP_OPEN_AD] ⏰ Còn ${remainingTime.inMinutes} phút nữa');
      }
      
      return canShow;
    } catch (e) {
      print('[APP_OPEN_AD] ❌ Error checking time: $e');
      return false;
    }
  }
  
  /// ✅ Save thời gian show ad
  static Future<void> _saveLastShownTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastShownTimeKey, now);
      print('[APP_OPEN_AD] 💾 Saved last shown time');
    } catch (e) {
      print('[APP_OPEN_AD] ❌ Error saving time: $e');
    }
  }
  
  /// ✅ Dispose ad
  static void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdLoaded = false;
    _isShowingAd = false;
  }
  
  /// ✅ Reset time (for testing)
  static Future<void> resetLastShownTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastShownTimeKey);
      print('[APP_OPEN_AD] 🔄 Reset last shown time');
    } catch (e) {
      print('[APP_OPEN_AD] ❌ Error resetting time: $e');
    }
  }
}

