import 'package:animage/utils/log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SearchDatabase {
  static const String _tag = 'SearchDatabase';

  static const _version = 1;

  static const String _dbName = 'search.db';
  static const String _searchHistoryTable = 'search_history';
  static const String _searchTerm = 'search_term';
  static const String _searchTime = 'search_time';

  static const String _currentFilterTable = 'current_filter';
  static const String _filterTerm = 'filter_term';
  static const String _filterApplyingTime = 'filter_applying_time';

  Database? _database;

  Future _openDataBase() async {
    if (_database != null && _database?.isOpen == true) {
      return;
    }
    await _database?.close();
    _database = await openDatabase(join(await getDatabasesPath(), _dbName),
        version: _version, onCreate: (db, version) async {
      await db.execute('create table $_currentFilterTable('
          '$_filterTerm string primary key,'
          '$_filterApplyingTime int)');
      await db.execute('create table $_searchHistoryTable('
          '$_searchTerm string primary key,'
          '$_searchTime int)');
    });
  }

  Future<bool> addFilter(String filter, int applyingTime) async {
    await _openDataBase();
    List<Map<String, dynamic>> filterList = await _database!.query(
      _currentFilterTable,
      columns: [_filterTerm],
      where: '$_filterTerm = "$filter"',
    );
    Log.d(_tag, 'filter $filter existed: ${filterList.isNotEmpty}');
    if (filterList.isNotEmpty) {
      return false;
    }
    return _database!.insert(_currentFilterTable, {
      _filterTerm: filter,
      _filterApplyingTime: applyingTime
    }).then((lastRowId) => lastRowId != 0);
  }

  Future<bool> addSearchHistory(String searchTerm, int searchTime) async {
    await _openDataBase();
    List<Map<String, dynamic>> historyList = await _database!.query(
      _searchHistoryTable,
      columns: [_searchTerm],
      where: '$_searchTerm = "$searchTerm"',
    );
    Log.d(_tag, 'search term $searchTerm existed: ${historyList.isNotEmpty}');
    if (historyList.isNotEmpty) {
      return false;
    }
    return _database!.insert(_searchHistoryTable, {
      _searchTerm: searchTerm,
      _searchTime: searchTime
    }).then((lastRowId) => lastRowId != 0);
  }

  Future<bool> deleteFilter(String filter) async {
    await _openDataBase();
    return _database!
        .delete(_currentFilterTable, where: '$_filterTerm = "$filter"')
        .then((deletedRows) => deletedRows > 0);
  }

  Future<bool> deleteSearchHistory(String searchTerm) async {
    await _openDataBase();
    List<Map<String, dynamic>> historyList = await _database!.query(
      _searchHistoryTable,
      columns: [_searchTerm],
      where: '$_searchTerm = "$searchTerm"',
    );
    Log.d(_tag, 'search term $searchTerm existed: ${historyList.isNotEmpty}');
    if (historyList.isNotEmpty) {
      return _database!
          .update(
              _searchHistoryTable, {_searchTerm: searchTerm, _searchTime: -1},
              where: '$_searchTerm = "$searchTerm"')
          .then((lastRowId) => lastRowId != 0);
    } else {
      return false;
    }
  }

  Future<List<String>> getCurrentFilter() async {
    await _openDataBase();

    List<Map<String, dynamic>> filterList = await _database!.query(
        _currentFilterTable,
        columns: [_filterTerm],
        orderBy: '$_filterApplyingTime asc');

    return filterList
        .map((Map<String, dynamic> map) => (map[_filterTerm] as String?) ?? '')
        .where((filter) => filter.isNotEmpty)
        .toList();
  }

  Future<List<String>> getSearchHistory() async {
    await _openDataBase();

    List<Map<String, dynamic>> historyList = await _database!.query(
        _searchHistoryTable,
        columns: [_searchTerm],
        orderBy: '$_searchTime desc',
        where: '$_searchTime > 0');

    return historyList
        .map((Map<String, dynamic> map) => (map[_searchTerm] as String?) ?? '')
        .where((searchTerm) => searchTerm.isNotEmpty)
        .toList();
  }
}
