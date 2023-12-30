import 'dart:io' show Platform;

import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final bool isIOS = Platform.isIOS;

const String galleryPref = 'gallery_pref';
const String galleryModeId = 'gallery_mode_id';
const String galleryLevel = 'gallery_level';
const String nextGalleryLevelUpTime = 'next_gallery_level_up_time';

Future<Box> openHiveBox(String boxName) async {
  if (!kIsWeb && !Hive.isBoxOpen(boxName)) {
    Hive.init((await getApplicationDocumentsDirectory()).path);
  }

  return await Hive.openBox(boxName);
}

void saveGalleryModePref(GalleryMode galleryMode) async {
  List<GalleryMode> modes = GalleryMode.values;
  for (int i = 0; i < modes.length; i++) {
    if (modes[i] == galleryMode) {
      Box galleryPrefBox = await openHiveBox(galleryPref);
      await galleryPrefBox.put(galleryModeId, i);
      return;
    }
  }
}

Future<GalleryMode> getCurrentGalleryMode() async {
  Box galleryPrefBox = await openHiveBox(galleryPref);
  int modeId = galleryPrefBox.get(galleryModeId) ?? 0;

  return GalleryMode.values.elementAt(modeId);
}

void saveGalleryLevelPref(int level, Duration duration) async {
  Box galleryPrefBox = await openHiveBox(galleryPref);
  int endTime = DateTime.now().millisecondsSinceEpoch + duration.inMilliseconds;
  await galleryPrefBox.put(
    galleryLevel,
    GalleryLevel(level: level, expirationTime: endTime),
  );
}

Future<Stream<GalleryLevel>> watchGalleryLevel() async {
  Box galleryPrefBox = await openHiveBox(galleryPref);

  return galleryPrefBox.watch(key: galleryLevel).map((event) => event.value);
}

Future<GalleryLevel> getCurrentGalleryLevel() async {
  Box galleryPrefBox = await openHiveBox(galleryPref);
  GalleryLevel? level = galleryPrefBox.get(galleryLevel);
  if (level == null) {
    return GalleryLevel(
      level: 0,
      expirationTime: DateTime.now().millisecondsSinceEpoch,
    );
  }
  if (level.level > 0 &&
      level.expirationTime < DateTime.now().millisecondsSinceEpoch) {
    saveGalleryLevelPref(0, const Duration());
    return GalleryLevel(
      level: 0,
      expirationTime: DateTime.now().millisecondsSinceEpoch,
    );
  } else {
    return level;
  }
}

Future<void> saveGalleryLevelUpTime(int millisecondsTime) async {
  Box galleryPrefBox = await openHiveBox(galleryPref);
  await galleryPrefBox.put(nextGalleryLevelUpTime, millisecondsTime);
}

Future<int> getGalleryLevelUpTime() async {
  Box galleryPrefBox = await openHiveBox(galleryPref);
  return galleryPrefBox.get(
    nextGalleryLevelUpTime,
    defaultValue: DateTime.now().millisecondsSinceEpoch,
  );
}
