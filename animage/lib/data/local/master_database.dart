import 'package:animage/constant.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MasterDatabase {
  Database? _database;

  static const _version = 1;

  static const String _dbName = 'master.db';
  static const String _artistTable = 'artist';
  static const String _artistName = 'name';
  static const String _aliasId = 'alias_id';
  static const String _groupId = 'group_id';
  static const String _urls = 'urls';

  static const int _nullIdValue = -1;

  Future _openDataBase() async {
    if (_database != null && _database?.isOpen == true) {
      return;
    }
    await _database?.close();
    _database = await openDatabase(join(await getDatabasesPath(), _dbName),
        version: _version, onCreate: (db, version) {
      db.execute('create table $_artistTable('
          '$id integer primary key,'
          '$_artistName string,'
          '$_aliasId int,'
          '$_groupId int,'
          '$_urls string)');
    });
  }

  Future<int> getArtistCount() async {
    int result = 0;
    await _openDataBase();
    result = Sqflite.firstIntValue(await _database!
            .rawQuery('select count($id) from $_artistTable')) ??
        0;
    return result;
  }

  Future<List<Artist>> getArtistList(List<int> artistIdList) async {
    List<Artist> resultList = [];
    await _openDataBase();
    List<Map<String, dynamic>> artistDbList = await _database!.query(
      _artistTable,
      columns: [id, _artistName, _aliasId, _groupId, _urls],
      where: '$id in (${artistIdList.join(',')})',
      orderBy: '$id asc',
    );

    resultList.addAll(artistDbList.map((Map<String, dynamic> artistMap) =>
        Artist(
            id: artistMap[id],
            name: artistMap[_artistName],
            aliasId: artistMap[_aliasId],
            groupId: artistMap[_groupId],
            urls: (artistMap[_urls] as String).split(' '))));
    return resultList;
  }

  Future<Artist?> getArtist(int artistId) async {
    await _openDataBase();
    List<Map<String, dynamic>> artistDbList = await _database!.query(
      _artistTable,
      columns: [id, _artistName, _aliasId, _groupId, _urls],
      where: '$id = ?',
      whereArgs: [artistId],
    );

    Artist? result;
    if (artistDbList.isNotEmpty) {
      result = Artist(
          id: artistDbList[0][id],
          name: artistDbList[0][_artistName],
          aliasId: artistDbList[0][_aliasId],
          groupId: artistDbList[0][_groupId],
          urls: (artistDbList[0][_urls] as String).split(' '));
    }

    return result;
  }

  Future<Map<int, Artist>> getArtistsFromPosts(List<Post> postList) async {
    await _openDataBase();
    Map<int, Artist> result = {};

    for (var post in postList) {
      List<String> tagList = post.tagList;

      List<Map<String, dynamic>> artistDbList = await _database!.query(
        _artistTable,
        columns: [id, _artistName, _aliasId, _groupId, _urls],
        where:
        '$_artistName in (${tagList.map((tag) => '"$tag"').join(',')})',
      );

      if (artistDbList.isNotEmpty) {
        result[post.id] = Artist(
            id: artistDbList[0][id],
            name: artistDbList[0][_artistName],
            aliasId: artistDbList[0][_aliasId],
            groupId: artistDbList[0][_groupId],
            urls: (artistDbList[0][_urls] as String).split(' '));
      }
    }

    return result;
  }

  Future insertArtist(List<Artist> artistList) async {
    await _openDataBase();
    Batch batch = _database!.batch();
    for (var artist in artistList) {
      batch.insert(_artistTable, {
        id: artist.id,
        _artistName: artist.name,
        _aliasId: artist.aliasId ?? _nullIdValue,
        _groupId: artist.groupId ?? _nullIdValue,
        _urls: artist.urls.join(' ')
      });
    }
    await batch.commit();
  }
}
