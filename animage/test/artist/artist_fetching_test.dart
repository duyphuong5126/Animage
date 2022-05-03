import 'dart:convert';
import 'dart:io';

import 'package:animage/data/remote/api_constant.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/artist/artist_list_change_log.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

void main() {
  test('Fetching all artists', () async {
    const int requestTimeOut = 120;
    const String tag = 'ArtistFetching';

    int page = 1;
    List<Artist> artistList = [];
    bool hasData = false;
    int successes = 0;
    int failures = 0;
    final stopwatch = Stopwatch()..start();
    do {
      Log.d(tag, 'Fetching page $page');
      String artistUrl =
          '${ApiConstant.baseUrl}/artist.json?${ApiConstant.apiVersionParam}=${ApiConstant.apiVersion}&${ApiConstant.page}=${page++}';
      try {
        Response response = await get(Uri.parse(artistUrl))
            .timeout(const Duration(seconds: requestTimeOut));
        List<dynamic> responseList = jsonDecode(response.body);
        Iterable<Artist> resultList =
            responseList.map((responseData) => Artist.fromJson(responseData));
        hasData = resultList.isNotEmpty;
        if (hasData) {
          artistList.addAll(resultList);
        }
        successes++;
        Log.d(tag,
            '\n-------------------\nGET $artistUrl\nResult: ${response.statusCode} - data=${resultList.length} - ${resultList.map((artist) => artist.id)}\n-------------------');
      } catch (e) {
        Log.d(tag,
            '\n-------------------\nGET $artistUrl\nError: $e\n-------------------');
        failures++;
      }
      Log.d(tag, 'success pages=$successes, failed pages=$failures');
    } while (hasData);

    File result = File('master_data/artist/artist.json');
    result.writeAsString(jsonEncode(artistList).toString(), flush: true);

    int finishTimeMillis = DateTime.now().millisecondsSinceEpoch;
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    ArtistListChangeLog artistListChangeLog = ArtistListChangeLog(
        currentVersionId: finishTimeMillis,
        updatedAt: formatter
            .format(DateTime.fromMillisecondsSinceEpoch(finishTimeMillis)));
    File changeLog = File('master_data/artist/artist_list_change_log.json');
    changeLog.writeAsString(jsonEncode(artistListChangeLog).toString(),
        flush: true);

    Log.d(tag,
        '\n-------------------\nFinish at ${artistListChangeLog.updatedAt}\nElapsed time: ${stopwatch.elapsed.inMinutes}\nSuccess pages=$successes\nFailed pages=$failures\n-------------------');
    stopwatch.stop();
  });
}
