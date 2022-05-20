import 'package:animage/app/animage_app_android.dart';
import 'package:animage/app/animage_app_ios.dart';
import 'package:animage/domain/use_case/check_artist_list_changed_use_case.dart';
import 'package:animage/domain/use_case/sync_artist_list_use_case.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CheckArtistListChangedUseCase _checkArtistListChangedUseCase =
      CheckArtistListChangedUseCaseImpl();
  SyncArtistListUseCase _syncArtistListUseCase = SyncArtistListUseCaseImpl();

  bool isArtistListChanged = await _checkArtistListChangedUseCase
      .execute()
      .onError((error, stackTrace) => false);
  Log.d('Initialization>>>', 'isArtistListChanged=$isArtistListChanged');
  if (isArtistListChanged) {
    await _syncArtistListUseCase.execute().onError((error, stackTrace) => null);
  }

  runApp(Platform.isIOS ? const AnimageAppIOS() : const AnimageAppAndroid());
}
