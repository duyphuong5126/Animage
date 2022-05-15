import 'package:animage/data/search_history_repository.dart';
import 'package:animage/domain/search_history_repository.dart';

abstract class AddSearchTermUseCase {
  Future<bool> execute(String searchTerm, int searchTime);
}

class AddSearchTermUseCaseImpl extends AddSearchTermUseCase {
  final SearchHistoryRepository _repository = SearchHistoryRepositoryImpl();

  @override
  Future<bool> execute(String searchTerm, int searchTime) =>
      _repository.addSearchTerm(searchTerm, searchTime);
}
