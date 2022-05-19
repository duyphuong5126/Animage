import 'package:animage/constant.dart';
import 'package:flutter/cupertino.dart';

extension CupertinoContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isDark => CupertinoTheme.of(this).brightness == Brightness.dark;

  Color get primaryColor => CupertinoTheme.of(this).primaryColor;

  Color get brandColor => accentColor;

  Color get brandColorDayNight => isDark ? accentColorLight : accentColor;

  Color get cardViewBackgroundColor {
    bool isDark = CupertinoTheme.of(this).brightness == Brightness.dark;
    return isDark ? CupertinoColors.white : CupertinoColors.systemGrey2;
  }

  Color get defaultBackgroundColor {
    bool isDark = CupertinoTheme.of(this).brightness == Brightness.dark;
    return isDark ? CupertinoColors.black : CupertinoColors.white;
  }

  double get safeAreaHeight {
    double height = MediaQuery.of(this).size.height;
    EdgeInsets padding = MediaQuery.of(this).padding;
    return height - padding.top - padding.bottom;
  }

  void showCupertinoConfirmationDialog(
      {required String title,
      required String message,
      required String actionLabel,
      required Function action,
      bool isDefaultAction = false}) {
    showCupertinoDialog(
        context: this,
        builder: (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: isDefaultAction,
                  child: Text(actionLabel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    action();
                  },
                ),
              ],
            ));
  }

  void showCupertinoYesNoDialog(
      {required String title,
      required String message,
      required String yesLabel,
      required Function yesAction,
      required String noLabel,
      required Function noAction,
      bool isYesDefaultAction = true}) {
    showCupertinoDialog(
        context: this,
        builder: (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: isYesDefaultAction,
                  child: Text(yesLabel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    yesAction();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: !isYesDefaultAction,
                  child: Text(noLabel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    noAction();
                  },
                )
              ],
            ));
  }

  TextStyle get navTitleTextStyle =>
      CupertinoTheme.of(this).textTheme.navTitleTextStyle;

  TextStyle get navActionTextStyle =>
      CupertinoTheme.of(this).textTheme.navActionTextStyle;

  TextStyle get navLargeTitleTextStyle =>
      CupertinoTheme.of(this).textTheme.navLargeTitleTextStyle;

  TextStyle get textStyle => CupertinoTheme.of(this).textTheme.textStyle;

  TextStyle get actionTextStyle =>
      CupertinoTheme.of(this).textTheme.actionTextStyle;

  TextStyle get dateTimePickerTextStyle =>
      CupertinoTheme.of(this).textTheme.dateTimePickerTextStyle;

  TextStyle get pickerTextStyle =>
      CupertinoTheme.of(this).textTheme.pickerTextStyle;

  TextStyle get tabLabelTextStyle =>
      CupertinoTheme.of(this).textTheme.tabLabelTextStyle;
}
