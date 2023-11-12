import 'package:animage/app/animage_app_android.dart';
import 'package:animage/app/animage_app_ios.dart';
import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/use_case/check_artist_list_changed_use_case.dart';
import 'package:animage/domain/use_case/sync_artist_list_use_case.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Hive.registerAdapter(GalleryLevelAdapter());

  CheckArtistListChangedUseCase checkArtistListChangedUseCase =
      CheckArtistListChangedUseCaseImpl();
  SyncArtistListUseCase syncArtistListUseCase = SyncArtistListUseCaseImpl();

  bool isArtistListChanged = await checkArtistListChangedUseCase
      .execute()
      .onError((error, stackTrace) => false);
  if (isArtistListChanged) {
    await syncArtistListUseCase.execute().onError((error, stackTrace) => null);
  }

  runApp(
    Platform.isIOS
        ? const AnimageAppIOS()
        : AnimageAppAndroid(isFromAndroid31: await _isFromAndroid31()),
  );
}

Future<bool> _isFromAndroid31() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt >= 31;
}
