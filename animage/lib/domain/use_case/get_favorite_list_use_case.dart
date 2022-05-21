import 'package:animage/data/local/favorite_local_data_source.dart';
import 'package:animage/domain/entity/post.dart';

abstract class GetFavoriteListUseCase {
  Future<List<Post>> execute(int skip, int take);
}

class GetFavoriteListUseCaseImpl extends GetFavoriteListUseCase {
  final FavoriteLocalDataSource _localDataSource =
      FavoriteLocalDataSourceImpl();

  @override
  Future<List<Post>> execute(int skip, int take) =>
      _localDataSource.getFavoriteList(skip, take);
}
