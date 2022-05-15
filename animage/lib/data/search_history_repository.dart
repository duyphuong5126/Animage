import 'package:animage/data/local/search_history_local_data_source.dart';
import 'package:animage/domain/search_history_repository.dart';

class SearchHistoryRepositoryImpl extends SearchHistoryRepository {
  final SearchHistoryLocalDataSource _localDataSource =
      SearchHistoryLocalDataSourceImpl();

  @override
  Future<bool> addSearchTerm(String searchTerm, int searchTime) =>
      _localDataSource.addSearchTerm(searchTerm, searchTime);

  @override
  Future<bool> deleteSearchTerm(String searchTerm) =>
      _localDataSource.deleteSearchTerm(searchTerm);

  @override
  Future<List<String>> getAllHistory() => _localDataSource.getAllHistory();
}
