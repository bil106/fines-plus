import 'dart:io';

class AdHelper {
  static bool get _isRelease => bool.fromEnvironment("dart.vm.product");

  static String get bannerAdUnitId {
    if (_isRelease) {
     return Platform.isAndroid ? "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-3940256099942544/2934735716";
    } else {
 
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-3940256099942544/2934735716";
    }
  }


  static String get interstitialAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid ? "ca-app-pub-1588977103337624/1111111111" : "ca-app-pub-1588977103337624/1111111111";
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/1033173712" : "ca-app-pub-3940256099942544/4411468910";
    }
  }


  static String get rewardedAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid ? "ca-app-pub-1588977103337624/2222222222" : "ca-app-pub-1588977103337624/2222222222";
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/5224354917" : "ca-app-pub-3940256099942544/1712485313";
    }
  }


  static String get nativeAdUnitId {
    if (_isRelease) {
      return Platform.isAndroid ? "ca-app-pub-1588977103337624/3333333333" : "ca-app-pub-1588977103337624/3333333333";
    } else {
      return Platform.isAndroid ? "ca-app-pub-3940256099942544/2247696110" : "ca-app-pub-3940256099942544/3986624511";
    }
  }
}
