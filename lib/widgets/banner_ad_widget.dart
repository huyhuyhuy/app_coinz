import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_helper.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final bannerAd = AdsHelper.createBannerAd();
    if (bannerAd == null) {
      // Không thể tạo ad (ví dụ trên web)
      setState(() {
        _isLoaded = true;
      });
      return;
    }
    
    _bannerAd = bannerAd;
    _bannerAd!.load().then((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    }).catchError((error) {
      print('Failed to load banner ad: $error');
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Loading Ad...',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (_bannerAd == null) {
      // Không có ad (ví dụ trên web) - ẩn widget
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
