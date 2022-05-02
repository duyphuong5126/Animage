import 'package:animage/domain/entity/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPostList(int page);

  Future<List<Post>> searchPostsByTag(String tag, int page);
}
