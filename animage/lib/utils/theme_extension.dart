import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension AndroidThemeColor on ThemeData {
  Color getCardViewBackgroundColor() {
    bool isDark = brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.grey[300]!;
  }

  bool get isDark => brightness == Brightness.dark;
}

extension IOSThemeColor on CupertinoThemeData {
  Color getCardViewBackgroundColor() {
    bool isDark = brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.grey[300]!;
  }

  bool get isDark => brightness == Brightness.dark;
}
