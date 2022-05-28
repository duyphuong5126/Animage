import 'package:animage/data/search_repository.dart';
import 'package:animage/domain/search_repository.dart';

abstract class DeleteSearchHistoryUseCase {
  Future<bool> execute(String searchTerm);
}

class DeleteSearchHistoryUseCaseImpl extends DeleteSearchHistoryUseCase {
  final SearchRepository _repository = SearchRepositoryImpl();

  @override
  Future<bool> execute(String searchTerm) =>
      _repository.deleteSearchHistory(searchTerm);
}
