import 'package:animage/data/search_repository.dart';
import 'package:animage/domain/search_repository.dart';

abstract class GetAllSearchFiltersUseCase {
  Future<List<String>> execute();
}

class GetAllSearchFiltersUseCaseImpl extends GetAllSearchFiltersUseCase {
  final SearchRepository _repository = SearchRepositoryImpl();

  @override
  Future<List<String>> execute() => _repository.getAllFilters();
}
