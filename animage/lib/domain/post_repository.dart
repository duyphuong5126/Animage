import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/entity/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPostList(int page);

  Future<List<Post>> searchPostsByTag(List<String> tags, int page);

  Future<void> updateGalleryLevel(int level, Duration existDuration);

  Future<GalleryLevel> getGalleryLevel();
}
