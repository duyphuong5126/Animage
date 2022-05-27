import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/favorite_repository.dart';
import 'package:animage/utils/log.dart';

abstract class ToggleFavoriteUseCase {
  Future<bool> execute(Post post);
}

class ToggleFavoriteUseCaseImpl extends ToggleFavoriteUseCase {
  static const String _tag = 'ToggleFavoriteUseCaseImpl';

  final FavoriteRepository _repository = FavoriteRepositoryImpl();

  @override
  Future<bool> execute(Post post) {
    return _repository
        .filterFavoriteList([post.id])
        .then((List<int> favoriteIds) => favoriteIds.isNotEmpty)
        .then((bool isFavorite) {
          Log.d(_tag, 'is ${post.id} favorite: $isFavorite');
          return isFavorite
              ? _repository.removeFavorite(post.id).then((value) => !isFavorite)
              : _repository.addFavoritePost(post).then((value) => !isFavorite);
        });
  }
}
