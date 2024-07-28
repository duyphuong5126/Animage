import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/post_repository.dart';

abstract class TemporarilyCancelSpecialOfferUseCase {
  Future<void> execute(int level);
}

class TemporarilyCancelSpecialOfferUseCaseImpl
    extends TemporarilyCancelSpecialOfferUseCase {
  late final PostRepository _repository = PostRepositoryImpl();

  @override
  Future<void> execute(int level) async {
    if (level < 0 && level >= 2) {
      return;
    }
    /*double timePeriod =
        GalleryLevel.levelExpirationMap[level]!.inMilliseconds / 2;*/
    final duration =
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
    await _repository.saveNextGalleryLevelUpTime(duration);
  }
}
