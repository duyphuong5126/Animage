import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/post_repository.dart';

abstract class GetNextLevelUpTime {
  Future<int> execute();
}

class GetNextLevelUpTimeImpl extends GetNextLevelUpTime {
  late final PostRepository _repository = PostRepositoryImpl();

  @override
  Future<int> execute() => _repository.getNextGalleryLevelUpTime();
}
