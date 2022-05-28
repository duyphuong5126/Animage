import 'package:animage/data/search_repository.dart';
import 'package:animage/domain/search_repository.dart';

abstract class AddSearchFilterUseCase {
  Future<bool> execute(String filter, int applyingTime);
}

class AddSearchFilterUseCaseImpl extends AddSearchFilterUseCase {
  final SearchRepository _repository = SearchRepositoryImpl();

  @override
  Future<bool> execute(String filter, int applyingTime) =>
      _repository.addFilter(filter, applyingTime);
}
