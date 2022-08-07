import 'package:animage/data/remote/post_remote_data_source.dart';
import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/post_repository.dart';
import 'package:animage/utils/utils.dart';

class PostRepositoryImpl implements PostRepository {
  late final PostRemoteDataSource _remoteDataSource =
      PostRemoteDataSourceImpl();

  @override
  Future<List<Post>> getPostList(int page) {
    return getCurrentGalleryLevel()
        .then((level) => _remoteDataSource.getPostList(page, level));
  }

  @override
  Future<List<Post>> searchPostsByTag(List<String> tags, int page) {
    return getCurrentGalleryLevel()
        .then((level) => _remoteDataSource.searchPostsByTag(tags, page, level));
  }

  @override
  Future<void> updateGalleryLevel(int level, Duration existDuration) async =>
      saveGalleryLevelPref(level, existDuration);

  @override
  Future<GalleryLevel> getGalleryLevel() {
    return getCurrentGalleryLevel().then((level) => level);
  }
}
