import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/post_repository.dart';

abstract class GetPostListUseCase {
  Future<List<Post>> execute(int page);
}

class GetPostListUseCaseImpl implements GetPostListUseCase {
  late final PostRepository _repository = PostRepositoryImpl();

  @override
  Future<List<Post>> execute(int page) {
    return _repository.getPostList(page);
  }
}
