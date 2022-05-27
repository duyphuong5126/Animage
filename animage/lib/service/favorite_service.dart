import 'package:animage/bloc/data_cubit.dart';

class FavoriteService {
  static final DataCubit<List<int>> favoriteListCubit = DataCubit([]);

  static void addFavorite(int postId) async {
    List<int> newList = [];
    newList.addAll(favoriteListCubit.state);
    if (!newList.contains(postId)) {
      newList.add(postId);
    }
    favoriteListCubit.push(newList);
  }

  static void addFavorites(Iterable<int> postIdList) async {
    List<int> newList = [];
    newList.addAll(favoriteListCubit.state);
    Iterable<int> notFavoriteIds =
        postIdList.where((id) => !newList.contains(id));
    newList.addAll(notFavoriteIds);
    favoriteListCubit.push(newList);
  }

  static void removeFavorite(int postId) async {
    List<int> newList = [];
    newList.addAll(favoriteListCubit.state);
    newList.remove(postId);
    favoriteListCubit.push(newList);
  }
}
