import 'package:animage/data/local/master_database.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/artist/artist_list_change_log.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract class ArtistLocalDataSource {
  Future<int> get artistCount;

  Future<int?> get localVersionId;

  Future<List<Artist>> getArtistList(List<int> artistIdList);

  Future<Artist?> getArtist(int artistId);

  Future insertArtist(List<Artist> artistList);

  Future saveChangeLog(ArtistListChangeLog changeLog);
}

class ArtistLocalDataSourceImpl extends ArtistLocalDataSource {
  final MasterDatabase _masterDatabase = MasterDatabase();

  static const String _artistChangeLog = 'artistChangeLog';

  @override
  Future<int> get artistCount => _masterDatabase.getArtistCount();

  @override
  Future<int?> get localVersionId async {
    Box changeLogBox = await _openHiveBox(_artistChangeLog);
    return changeLogBox.get('currentVersionId');
  }

  @override
  Future<Artist?> getArtist(int artistId) {
    return _masterDatabase.getArtist(artistId);
  }

  @override
  Future<List<Artist>> getArtistList(List<int> artistIdList) {
    return _masterDatabase.getArtistList(artistIdList);
  }

  @override
  Future insertArtist(List<Artist> artistList) {
    return _masterDatabase.insertArtist(artistList);
  }

  @override
  Future saveChangeLog(ArtistListChangeLog changeLog) async {
    Box changeLogBox = await _openHiveBox(_artistChangeLog);
    await changeLogBox.put('currentVersionId', changeLog.currentVersionId);
    await changeLogBox.put('updatedAt', changeLog.updatedAt);
  }

  Future<Box> _openHiveBox(String boxName) async {
    if (!kIsWeb && !Hive.isBoxOpen(boxName)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
    }

    return await Hive.openBox(boxName);
  }
}
