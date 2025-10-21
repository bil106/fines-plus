import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/extensions/subscription_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize size;

  const AdBannerWidget({super.key, this.size = AdSize.largeBanner});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

void _loadBanner() {
    if (_bannerAd != null || _isLoading) return;
    _isLoading = true;

    debugPrint("🚀 Starting to load banner...");

    final banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("✅ Banner uploaded successfully!");
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Error loading banner: $error");
          ad.dispose();
          _isLoading = false;
        },
        onAdOpened: (_) => debugPrint("📢 The banner was opened by the user"),
        onAdClosed: (_) => debugPrint("📪 The banner is closed"),
        onAdImpression: (_) => debugPrint("👁 The banner is shown to the user"),
      ),
    );

    banner.load();
  }


  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
     
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: SubscriptionHelper.isUserSubscribed(user.uid),
      builder: (context, snapshot) {
    
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

     
        if (snapshot.data == true) {
          debugPrint("🚫 User with active subscription - ads hidden");
          return const SizedBox.shrink();
        }

    
        if (_bannerAd == null) {
          debugPrint("ℹ️Advertisement not loaded yet");
          return const SizedBox.shrink();
        }

       
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      },
    );
  }
}
