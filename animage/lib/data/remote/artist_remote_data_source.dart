import 'dart:convert';

import 'package:animage/app_const.dart';
import 'package:animage/data/remote/api_constant.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/artist/artist_list_change_log.dart';
import 'package:animage/utils/log.dart';
import 'package:http/http.dart';

abstract class ArtistRemoteDataSource {
  Future<List<Artist>> fetchArtistList();

  Future<ArtistListChangeLog?> fetchChangeLog();
}

class ArtistRemoteDataSourceImpl extends ArtistRemoteDataSource {
  static const int requestTimeOut = 120;

  static const String tag = 'ArtistRemoteDataSourceImpl';

  @override
  Future<List<Artist>> fetchArtistList() async {
    String artistUrl = '$baseUrlMasterData/${ApiConstant.artist}';

    List<Artist> resultList = [];
    try {
      Response response = await get(Uri.parse(artistUrl))
          .timeout(const Duration(seconds: requestTimeOut));
      List<dynamic> responseList = jsonDecode(response.body);

      resultList.addAll(
          responseList.map((responseData) => Artist.fromJson(responseData)));
      Log.d(tag,
          '\n-------------------\nGET $artistUrl\nResult: ${response.statusCode} - data=${resultList.length} - ${resultList.map((artist) => artist.id)}\n-------------------');
    } catch (e) {
      Log.d(tag,
          '\n-------------------\nGET $artistUrl\nError: $e\n-------------------');
    }

    return resultList;
  }

  @override
  Future<ArtistListChangeLog?> fetchChangeLog() async {
    String changeLogUrl = '$baseUrlMasterData/${ApiConstant.artistChangeLog}';

    ArtistListChangeLog? changeLog;
    try {
      Response response = await get(Uri.parse(changeLogUrl))
          .timeout(const Duration(seconds: requestTimeOut));
      Map responseMap = jsonDecode(response.body);

      int? currentVersionId = responseMap['current_version_id'] as int?;
      String? updatedAt = responseMap['updated_at'] as String?;
      if (currentVersionId != null && updatedAt != null) {
        changeLog = ArtistListChangeLog(
            currentVersionId: currentVersionId, updatedAt: updatedAt);
      }

      Log.d(tag,
          '\n-------------------\nGET $changeLogUrl\nResult: ${response.statusCode} - current_version_id=$currentVersionId, updated_at=$updatedAt\n-------------------');
    } catch (e) {
      Log.d(tag,
          '\n-------------------\nGET $changeLogUrl\nError: $e\n-------------------');
    }

    return changeLog;
  }
}
