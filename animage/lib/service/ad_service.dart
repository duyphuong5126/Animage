import 'dart:io';

import 'package:animage/app_const.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static String get bannerAdId {
    if (Platform.isAndroid) {
      return _androidBannerAdId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get firstRewardedAdId {
    if (Platform.isAndroid) {
      return _androidFirstRewardedAdId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get secondRewardedAdId {
    if (Platform.isAndroid) {
      return _androidSecondRewardedAdId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get _androidBannerAdId => kReleaseMode
      ? androidBannerAdId
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get _androidFirstRewardedAdId => kReleaseMode
      ? androidFirstRewardedAdId
      : 'ca-app-pub-3940256099942544/5224354917';

  static String get _androidSecondRewardedAdId => kReleaseMode
      ? androidSecondRewardedAdId
      : 'ca-app-pub-3940256099942544/5224354917';
}
