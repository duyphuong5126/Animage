import 'package:animage/data/local/master_database.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/artist/artist_list_change_log.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract class ArtistLocalDataSource {
  Future<int> get artistCount;

  Future<int?> get localVersionId;

  Future<Map<int, Artist>> getArtists(List<Post> postList);

  Future<Artist?> getArtist(Post post);

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
  Future<Artist?> getArtist(Post post) {
    return _masterDatabase.getArtistsFromPosts([post]).then(
        (artistMap) => Future.value(artistMap[post.id]));
  }

  @override
  Future<Map<int, Artist>> getArtists(List<Post> postList) {
    return _masterDatabase.getArtistsFromPosts(postList);
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
