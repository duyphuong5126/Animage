import 'package:animage/data/remote/post_remote_data_source.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  late final PostRemoteDataSource _remoteDataSource =
      PostRemoteDataSourceImpl();

  @override
  Future<List<Post>> getPostList(int page) {
    return _remoteDataSource.getPostList(page);
  }

  @override
  Future<List<Post>> searchPostsByTag(String tag, int page) {
    return _remoteDataSource.searchPostsByTag(tag, page);
  }
}
