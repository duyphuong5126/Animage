import 'dart:developer';

import 'package:flutter/foundation.dart';

class Log {
  static void d(String tag, String message) {
    if (kDebugMode) {
      print('$tag: $message');
    }
  }
}

extension LogExtension on Object {
  logD(String message, [String? tag]) {
    if (kDebugMode) {
      final tagName = tag ?? runtimeType.toString();
      log('$tagName: $message');
    }
  }

  logE(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final tagName = tag ?? runtimeType.toString();
      log('$tagName: $message', error: error, stackTrace: stackTrace);
    }
  }
}
