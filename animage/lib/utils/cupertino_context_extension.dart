import 'package:flutter/cupertino.dart';

extension CupertinoContextExtension on BuildContext {
  bool get isDark => CupertinoTheme.of(this).brightness == Brightness.dark;

  Color get primaryColor => CupertinoTheme.of(this).primaryColor;

  Color get cardViewBackgroundColor {
    bool isDark = CupertinoTheme.of(this).brightness == Brightness.dark;
    return isDark ? CupertinoColors.white : CupertinoColors.systemGrey2;
  }
}
