import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/post_repository.dart';

abstract class GetGalleryLevelUseCase {
  Future<GalleryLevel> execute();
}

class GetGalleryLevelUseCaseImpl extends GetGalleryLevelUseCase {
  late final PostRepository _repository = PostRepositoryImpl();

  @override
  Future<GalleryLevel> execute() => _repository.getGalleryLevel();
}
