import 'package:animage/bloc/data_cubit.dart';

class FavoriteService {
  static final DataCubit<List<int>> favoriteListCubit = DataCubit([]);
  static final DataCubit<int> favoriteUpdatedTimeCubit = DataCubit(-1);

  static void addFavorite(int postId) async {
    List<int> newList = [];
    newList.addAll(favoriteListCubit.state);
    if (newList.contains(postId)) {
      return;
    }
    newList.add(postId);
    favoriteListCubit.push(newList);
    favoriteUpdatedTimeCubit.push(DateTime.now().millisecondsSinceEpoch);
  }

  static void addFavorites(Iterable<int> postIdList) async {
    List<int> newList = [];
    newList.addAll(favoriteListCubit.state);
    if (postIdList.isEmpty ||
        postIdList.where((inputId) => !newList.contains(inputId)).isEmpty) {
      return;
    }
    Iterable<int> notFavoriteIds =
        postIdList.where((id) => !newList.contains(id));
    newList.addAll(notFavoriteIds);
    favoriteListCubit.push(newList);
    favoriteUpdatedTimeCubit.push(DateTime.now().millisecondsSinceEpoch);
  }

  static void removeFavorite(int postId) async {
    List<int> newList = [];
    newList.addAll(favoriteListCubit.state);
    if (!newList.contains(postId)) {
      return;
    }
    newList.remove(postId);
    favoriteListCubit.push(newList);
    favoriteUpdatedTimeCubit.push(DateTime.now().millisecondsSinceEpoch);
  }
}
