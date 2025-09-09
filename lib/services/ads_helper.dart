import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdsHelper {
  static String get bannerAdUnitId {
    // Test ad unit ID - thay thế bằng ID thật khi publish
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get interstitialAdUnitId {
    // Test ad unit ID - thay thế bằng ID thật khi publish
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get rewardedAdUnitId {
    // Test ad unit ID - thay thế bằng ID thật khi publish
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  static Future<void> initialize() async {
    // Chỉ khởi tạo ads trên mobile, không phải web
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
    }
  }

  static BannerAd? createBannerAd() {
    // Không tạo ads trên web
    if (kIsWeb) return null;
    
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Interstitial ad not ready yet');
    }
  }

  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('Rewarded ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  static Future<void> showRewardedAd({
    required Function() onRewarded,
  }) async {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Rewarded ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          onRewarded();
        },
      );
    } else {
      print('Rewarded ad not ready yet');
    }
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
