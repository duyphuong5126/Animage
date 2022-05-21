import 'package:animage/data/local/favorite_local_data_source.dart';
import 'package:animage/domain/entity/post.dart';

abstract class FavoriteRepository {
  Future<List<Post>> getFavoriteList(int skip, int take);

  Future<List<int>> filterFavoriteList(List<int> postIdList);

  Future<bool> addFavoritePost(Post post);

  Future<bool> removeFavorite(int postId);
}

class FavoriteRepositoryImpl extends FavoriteRepository {
  final FavoriteLocalDataSource _localDataSource =
      FavoriteLocalDataSourceImpl();

  @override
  Future<bool> addFavoritePost(Post post) =>
      _localDataSource.addFavoritePost(post);

  @override
  Future<List<int>> filterFavoriteList(List<int> postIdList) =>
      _localDataSource.filterFavoriteList(postIdList);

  @override
  Future<List<Post>> getFavoriteList(int skip, int take) =>
      _localDataSource.getFavoriteList(skip, take);

  @override
  Future<bool> removeFavorite(int postId) =>
      _localDataSource.removeFavorite(postId);
}
