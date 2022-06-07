import 'dart:io';

import 'package:flutter/foundation.dart';

class AdService {
  static String get bannerAdId {
    if (Platform.isAndroid) {
      return androidBannerAdId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get androidBannerAdId => kReleaseMode
      ? 'ca-app-pub-4399638162592093/3369299528'
      : 'ca-app-pub-3940256099942544/6300978111';
}
