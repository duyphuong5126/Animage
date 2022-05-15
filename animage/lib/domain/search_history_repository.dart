abstract class SearchHistoryRepository {
  Future<bool> addSearchTerm(String searchTerm, int searchTime);

  Future<bool> deleteSearchTerm(String searchTerm);

  Future<List<String>> getAllHistory();
}
