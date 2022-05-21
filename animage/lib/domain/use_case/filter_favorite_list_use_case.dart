import 'package:animage/data/local/favorite_local_data_source.dart';

abstract class FilterFavoriteListUseCase {
  Future<List<int>> execute(List<int> postIdList);
}

class FilterFavoriteListUseCaseImpl extends FilterFavoriteListUseCase {
  final FavoriteLocalDataSource _localDataSource =
      FavoriteLocalDataSourceImpl();

  @override
  Future<List<int>> execute(List<int> postIdList) =>
      _localDataSource.filterFavoriteList(postIdList);
}
