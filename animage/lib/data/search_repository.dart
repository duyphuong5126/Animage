import 'package:animage/data/local/search_local_data_source.dart';
import 'package:animage/domain/search_repository.dart';

class SearchRepositoryImpl extends SearchRepository {
  final SearchLocalDataSource _localDataSource = SearchLocalDataSourceImpl();

  @override
  Future<bool> addFilter(String filter, int applyingTime) =>
      _localDataSource.addFilter(filter, applyingTime);

  @override
  Future<bool> deleteFilter(String filter) =>
      _localDataSource.deleteFilter(filter);

  @override
  Future<List<String>> getAllFilters() => _localDataSource.getAllFilters();

  @override
  Future<bool> addSearchHistory(String searchTerm, int searchTime) =>
      _localDataSource.addSearchHistory(searchTerm, searchTime);

  @override
  Future<bool> deleteSearchHistory(String searchTerm) =>
      _localDataSource.deleteSearchHistory(searchTerm);

  @override
  Future<List<String>> getSearchHistory() =>
      _localDataSource.getSearchHistory();
}
