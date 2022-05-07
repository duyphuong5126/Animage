import 'package:animage/constant.dart';
import 'package:animage/widget/android_confirmation_alert_dialog.dart';
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

  TextStyle? get headline1 => Theme.of(this).textTheme.headline1;

  TextStyle? get headline2 => Theme.of(this).textTheme.headline2;

  TextStyle? get headline3 => Theme.of(this).textTheme.headline3;

  TextStyle? get headline4 => Theme.of(this).textTheme.headline4;

  TextStyle? get headline5 => Theme.of(this).textTheme.headline5;

  TextStyle? get headline6 => Theme.of(this).textTheme.headline6;

  TextStyle? get bodyText1 => Theme.of(this).textTheme.bodyText1;

  TextStyle? get bodyText2 => Theme.of(this).textTheme.bodyText2;

  TextStyle? get subtitle1 => Theme.of(this).textTheme.subtitle1;

  TextStyle? get subtitle2 => Theme.of(this).textTheme.subtitle2;

  TextStyle? get button => Theme.of(this).textTheme.button;

  TextStyle? get caption => Theme.of(this).textTheme.caption;

  TextStyle? get overLine => Theme.of(this).textTheme.overline;

  void showConfirmationDialog(
      {required String title,
      required String message,
      required String actionLabel,
      required Function action}) {
    showDialog(
        context: this,
        builder: (context) {
          return AndroidConfirmationAlertDialog(
              title: title,
              content: message,
              confirmLabel: actionLabel,
              confirmAction: action);
        });
  }
}
