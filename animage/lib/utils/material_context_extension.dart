import 'package:animage/constant.dart';
import 'package:flutter/material.dart';

extension MaterialContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get defaultSecondaryColor {
    return Theme.of(this).colorScheme.secondary;
  }

  Color get defaultBackgroundColor {
    return Theme.of(this).backgroundColor;
  }

  Color get defaultShadowColor {
    return Theme.of(this).shadowColor;
  }

  Color get primaryColor {
    return Theme.of(this).primaryColor;
  }

  Color get secondaryColor {
    return accentColor;
  }

  Color get cardViewBackgroundColor {
    bool isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.grey[300]!;
  }
}
