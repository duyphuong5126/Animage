import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/entity/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPostList(int page);

  Future<List<Post>> searchPostsByTag(List<String> tags, int page);

  Future<List<Post>> searchPostsByTagDebug(
    List<String> tags,
    int page,
    GalleryLevel level,
  );

  Future<void> updateGalleryLevel(int level, Duration existDuration);

  Future<void> saveNextGalleryLevelUpTime(int millisecondsTime);

  Future<int> getNextGalleryLevelUpTime();

  Future<GalleryLevel> getGalleryLevel();
}
