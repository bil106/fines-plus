import 'dart:io';


class AdHelper {
  static bool get _isRelease => bool.fromEnvironment("dart.vm.product");

  //🔹 Banner
  static String get bannerAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid
          ? "ca-app-pub-XXXXXX/XXXXXX" // real id android
          : "ca-app-pub-XXXXXX/XXXXXX"; // real ios id
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-3940256099942544/2934735716";
    }
  }

  // 🔹 Interstitial
  static String get interstitialAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid ? "ca-app-pub-XXXXXX/XXXXXX" : "ca-app-pub-XXXXXX/XXXXXX";
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/1033173712" : "ca-app-pub-3940256099942544/4411468910";
    }
  }

  // 🔹 Rewarded
  static String get rewardedAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid ? "ca-app-pub-XXXXXX/XXXXXX" : "ca-app-pub-XXXXXX/XXXXXX";
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/5224354917" : "ca-app-pub-3940256099942544/1712485313";
    }
  }

  // 🔹Native Advanced
  static String get nativeAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid ? "ca-app-pub-XXXXXX/XXXXXX" : "ca-app-pub-XXXXXX/XXXXXX";
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/2247696110" : "ca-app-pub-3940256099942544/3986624511";
    }
  }
}
