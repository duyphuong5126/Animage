import 'package:animage/data/configs_repository_impl.dart';
import 'package:animage/domain/configs_repository.dart';

abstract class CheckGalleryLevelingEnabledUseCase {
  Future<bool> execute();
}

class CheckGalleryLevelingEnabledUseCaseImpl
    extends CheckGalleryLevelingEnabledUseCase {
  late final ConfigsRepository _repository = ConfigsRepositoryImpl();

  @override
  Future<bool> execute() => _repository.isGalleryLevelingEnable();
}
