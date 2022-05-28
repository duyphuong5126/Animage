abstract class SearchRepository {
  Future<bool> addFilter(String filter, int applyingTime);

  Future<bool> deleteFilter(String filter);

  Future<List<String>> getAllFilters();
}
