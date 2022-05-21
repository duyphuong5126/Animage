import 'package:animage/data/local/database/favorite_database.dart';
import 'package:animage/domain/entity/post.dart';

abstract class FavoriteLocalDataSource {
  Future<List<Post>> getFavoriteList(int skip, int take);

  Future<List<int>> filterFavoriteList(List<int> postIdList);

  Future<bool> addFavoritePost(Post post);

  Future<bool> removeFavorite(int postId);
}

class FavoriteLocalDataSourceImpl extends FavoriteLocalDataSource {
  final FavoriteDatabase _database = FavoriteDatabase();

  @override
  Future<bool> addFavoritePost(Post post) => _database.addFavoritePost(post);

  @override
  Future<List<int>> filterFavoriteList(List<int> postIdList) =>
      _database.filterFavoriteList(postIdList);

  @override
  Future<List<Post>> getFavoriteList(int skip, int take) =>
      _database.getFavoriteList(skip, take);

  @override
  Future<bool> removeFavorite(int postId) => _database.removeFavorite(postId);
}
