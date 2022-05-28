abstract class SearchRepository {
  Future<bool> addFilter(String filter, int applyingTime);

  Future<bool> deleteFilter(String filter);

  Future<List<String>> getAllFilters();

  Future<bool> addSearchHistory(String searchTerm, int searchTime);

  Future<bool> deleteSearchHistory(String searchTerm);

  Future<List<String>> getSearchHistory();
}
