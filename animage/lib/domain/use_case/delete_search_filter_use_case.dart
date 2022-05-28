import 'package:animage/data/search_repository.dart';
import 'package:animage/domain/search_repository.dart';

abstract class DeleteSearchFilterUseCase {
  Future<bool> execute(String filter);
}

class DeleteSearchFilterUseCaseImpl extends DeleteSearchFilterUseCase {
  final SearchRepository _repository = SearchRepositoryImpl();

  @override
  Future<bool> execute(String filter) => _repository.deleteFilter(filter);
}
