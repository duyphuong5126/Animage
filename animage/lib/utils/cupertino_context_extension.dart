import 'package:animage/constant.dart';
import 'package:flutter/cupertino.dart';

extension CupertinoContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isDark => CupertinoTheme.of(this).brightness == Brightness.dark;

  Color get primaryColor => CupertinoTheme.of(this).primaryColor;

  Color get brandColor => accentColor;

  Color get cardViewBackgroundColor {
    bool isDark = CupertinoTheme.of(this).brightness == Brightness.dark;
    return isDark ? CupertinoColors.white : CupertinoColors.systemGrey2;
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
