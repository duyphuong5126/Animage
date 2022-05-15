import 'package:animage/data/search_history_repository.dart';
import 'package:animage/domain/search_history_repository.dart';

abstract class GetAllSearchHistoryUseCase {
  Future<List<String>> execute();
}

class GetAllSearchHistoryUseCaseImpl extends GetAllSearchHistoryUseCase {
  final SearchHistoryRepository _repository = SearchHistoryRepositoryImpl();

  @override
  Future<List<String>> execute() => _repository.getAllHistory();
}
