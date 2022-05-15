import 'package:animage/utils/log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SearchHistoryDatabase {
  static const String _tag = 'SearchHistoryDatabase';

  static const _version = 1;

  static const String _dbName = 'search_history.db';
  static const String _searchHistoryTable = 'search_history';
  static const String _searchTerm = 'search_term';
  static const String _searchTime = 'search_time';

  Database? _database;

  Future _openDataBase() async {
    if (_database != null && _database?.isOpen == true) {
      return;
    }
    await _database?.close();
    _database = await openDatabase(join(await getDatabasesPath(), _dbName),
        version: _version, onCreate: (db, version) {
      db.execute('create table $_searchHistoryTable('
          '$_searchTerm string primary key,'
          '$_searchTime int)');
    });
  }

  Future<bool> addSearchTerm(String searchTerm, int searchTime) async {
    await _openDataBase();
    List<Map<String, dynamic>> historyList = await _database!.query(
      _searchHistoryTable,
      columns: [_searchTerm],
      where: '$_searchTerm = "$searchTerm"',
    );
    Log.d(_tag, 'searchTerm $searchTerm existed: ${historyList.isNotEmpty}');
    if (historyList.isNotEmpty) {
      return false;
    }
    return _database!.insert(_searchHistoryTable, {
      _searchTerm: searchTerm,
      _searchTime: searchTime
    }).then((lastRowId) => lastRowId != 0);
  }

  Future<bool> deleteSearchTerm(String searchTerm) async {
    await _openDataBase();
    return _database!
        .delete(_searchHistoryTable, where: '$_searchTerm = "$searchTerm"')
        .then((deletedRows) => deletedRows > 0);
  }

  Future<List<String>> getAllHistory() async {
    await _openDataBase();

    List<Map<String, dynamic>> historyList = await _database!.query(
        _searchHistoryTable,
        columns: [_searchTerm],
        orderBy: '$_searchTime asc');

    return historyList
        .map((Map<String, dynamic> map) => (map[_searchTerm] as String?) ?? '')
        .where((searchTerm) => searchTerm.isNotEmpty)
        .toList();
  }
}
