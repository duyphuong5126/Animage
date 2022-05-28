import 'package:animage/data/local/database/search_database.dart';

abstract class SearchLocalDataSource {
  Future<bool> addFilter(String filter, int applyingTime);

  Future<bool> deleteFilter(String filter);

  Future<List<String>> getAllFilters();

  Future<bool> addSearchHistory(String searchTerm, int searchTime);

  Future<bool> deleteSearchHistory(String searchTerm);

  Future<List<String>> getSearchHistory();
}

class SearchLocalDataSourceImpl extends SearchLocalDataSource {
  final SearchDatabase _database = SearchDatabase();

  @override
  Future<bool> addFilter(String filter, int applyingTime) {
    return _database.addFilter(filter, applyingTime);
  }

  @override
  Future<bool> deleteFilter(String filter) {
    return _database.deleteFilter(filter);
  }

  @override
  Future<List<String>> getAllFilters() {
    return _database.getCurrentFilter();
  }

  @override
  Future<bool> addSearchHistory(String searchTerm, int searchTime) =>
      _database.addSearchHistory(searchTerm, searchTime);

  @override
  Future<bool> deleteSearchHistory(String searchTerm) =>
      _database.deleteSearchHistory(searchTerm);

  @override
  Future<List<String>> getSearchHistory() => _database.getSearchHistory();
}
