import 'package:flutter/foundation.dart';

class Log {
  static void d(String tag, String message) {
    if (kDebugMode) {
      print('$tag: $message');
    }
  }
}
