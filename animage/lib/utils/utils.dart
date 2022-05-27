import 'dart:io' show Platform;

import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final bool isIOS = Platform.isIOS;

const String galleryPref = 'gallery_pref';
const String galleryModeId = 'gallery_mode_id';

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
