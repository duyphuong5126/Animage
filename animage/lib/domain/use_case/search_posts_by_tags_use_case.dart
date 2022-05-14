import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/post_repository.dart';

abstract class SearchPostsByTagsUseCase {
  Future<List<Post>> execute(List<String> tags, int page);
}

class SearchPostsByTagsUseCaseImpl extends SearchPostsByTagsUseCase {
  late final PostRepository _repository = PostRepositoryImpl();

  @override
  Future<List<Post>> execute(List<String> tags, int page) {
    return _repository.searchPostsByTag(tags, page);
  }
}
