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
  bool _isSubscribed = true;
  bool _checkingSubscription = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndLoadAd();
  }

  Future<void> _checkSubscriptionAndLoadAd() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _checkingSubscription = false);
      return;
    }

    final subscribed = await SubscriptionHelper.isUserSubscribed(user.uid);

    if (!mounted) return;

    setState(() {
      _isSubscribed = subscribed;
      _checkingSubscription = false;
    });

    if (!subscribed) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    if (_bannerAd != null || _isLoading) return;
    _isLoading = true;

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoading = false);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoading = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSubscription || _isSubscribed) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null) {
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
  }
}
