import 'package:animage/data/local/database/search_history_database.dart';

abstract class SearchHistoryLocalDataSource {
  Future<bool> addSearchTerm(String searchTerm, int searchTime);

  Future<bool> deleteSearchTerm(String searchTerm);

  Future<List<String>> getAllHistory();
}

class SearchHistoryLocalDataSourceImpl extends SearchHistoryLocalDataSource {
  final SearchHistoryDatabase _database = SearchHistoryDatabase();

  @override
  Future<bool> addSearchTerm(String searchTerm, int searchTime) {
    return _database.addSearchTerm(searchTerm, searchTime);
  }

  @override
  Future<bool> deleteSearchTerm(String searchTerm) {
    return _database.deleteSearchTerm(searchTerm);
  }

  @override
  Future<List<String>> getAllHistory() {
    return _database.getAllHistory();
  }
}
