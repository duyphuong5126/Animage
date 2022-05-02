import 'package:animage/app/animage_app_android.dart';
import 'package:animage/app/animage_app_iOS.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

void main() {
  runApp(Platform.isIOS ? const AnimageAppIOS() : const AnimageAppAndroid());
}
