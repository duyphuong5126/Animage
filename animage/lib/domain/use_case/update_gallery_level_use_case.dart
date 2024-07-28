import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/post_repository.dart';

abstract class UpdateGalleryLevelUseCase {
  Future<void> execute(int level);
}

class UpdateGalleryLevelUseCaseImpl extends UpdateGalleryLevelUseCase {
  late final PostRepository _repository = PostRepositoryImpl();

  @override
  Future<void> execute(int level) => _repository.updateGalleryLevel(
        level,
        GalleryLevel.levelExpirationMap[level] ?? const Duration(),
      );
}
