import 'dart:convert';
import 'dart:io';

import 'package:animage/app_const.dart';
import 'package:animage/data/remote/api_constant.dart';
import 'package:animage/utils/log.dart';
import 'package:http/http.dart';

abstract class ConfigsRemoteDataSource {
  Future<bool> isGalleryLevelingEnable();
}

class ConfigsRemoteDataSourceImpl extends ConfigsRemoteDataSource {
  static const String _tag = 'ConfigsRemoteDataSourceImpl';

  static const String configServerUrl =
      '$baseUrlMasterData/${ApiConstant.configs}';

  @override
  Future<bool> isGalleryLevelingEnable() async {
    try {
      Response response = await get(Uri.parse(configServerUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        String targetElement = Platform.isAndroid
            ? 'is_android_gallery_leveling_enabled'
            : 'is_ios_gallery_leveling_enabled';
        return body[targetElement] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      Log.d(_tag, 'Failed to get configs with error $e');
      return false;
    }
  }
}
