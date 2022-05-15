import 'package:animage/data/search_history_repository.dart';
import 'package:animage/domain/search_history_repository.dart';

abstract class DeleteSearchTermUseCase {
  Future<bool> execute(String searchTerm);
}

class DeleteSearchTermUseCaseImpl extends DeleteSearchTermUseCase {
  final SearchHistoryRepository _repository = SearchHistoryRepositoryImpl();

  @override
  Future<bool> execute(String searchTerm) =>
      _repository.deleteSearchTerm(searchTerm);
}
