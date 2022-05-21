import 'dart:convert';

import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavoriteDatabase {
  Database? _database;

  static const _version = 1;

  static const String _dbName = 'favorite.db';
  static const String _favoriteTable = 'favorite';
  static const String _postJson = 'post_json';
  static const String _favoriteTime = 'favorite_time';

  Future _openDataBase() async {
    if (_database != null && _database?.isOpen == true) {
      return;
    }
    await _database?.close();
    _database = await openDatabase(join(await getDatabasesPath(), _dbName),
        version: _version, onCreate: (db, version) {
      db.execute('create table $_favoriteTable('
          '$id integer primary key,'
          '$_postJson string,'
          '$_favoriteTime int)');
    });
  }

  Future<List<Post>> getFavoriteList(int skip, int take) async {
    await _openDataBase();
    List<Map<String, dynamic>> favoriteList = await _database!
        .query(_favoriteTable, columns: [_postJson], limit: take, offset: skip);

    return favoriteList
        .map((Map<String, dynamic> data) =>
            Post.fromJson(jsonDecode(data[_postJson] as String)))
        .toList();
  }

  Future<List<int>> filterFavoriteList(List<int> postIdList) async {
    await _openDataBase();
    List<Map<String, dynamic>> favoriteList = await _database!.query(
        _favoriteTable,
        columns: [id],
        where: '$id in (${postIdList.join(',')}) and $_favoriteTime > 0');

    return favoriteList
        .map((Map<String, dynamic> data) => data[id] as int)
        .toList();
  }

  Future<bool> addFavoritePost(Post post) async {
    await _openDataBase();
    List<Map<String, dynamic>> favoriteList = await _database!.query(
      _favoriteTable,
      columns: [id],
      where: '$id = ${post.id}',
    );
    int timeMillis = DateTime.now().millisecondsSinceEpoch;
    if (favoriteList.isNotEmpty) {
      int changes = await _database!.update(
          _favoriteTable, {_favoriteTime: timeMillis},
          where: '$id = ?', whereArgs: [post.id]);
      return changes > 0;
    } else {
      int result = await _database!.insert(_favoriteTable, {
        id: post.id,
        _postJson: post.toJson().toString(),
        _favoriteTime: timeMillis
      });
      return result > 0;
    }
  }

  Future<bool> removeFavorite(int postId) async {
    await _openDataBase();
    int changes = await _database!.update(_favoriteTable, {_favoriteTime: -1},
        where: '$id = ?', whereArgs: [postId]);
    return changes > 0;
  }
}
