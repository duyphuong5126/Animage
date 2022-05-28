import 'package:animage/data/search_repository.dart';
import 'package:animage/domain/search_repository.dart';

abstract class GetSearchHistoryUseCase {
  Future<List<String>> execute();
}

class GetSearchHistoryUseCaseImpl extends GetSearchHistoryUseCase {
  final SearchRepository _repository = SearchRepositoryImpl();

  @override
  Future<List<String>> execute() => _repository.getSearchHistory();
}
