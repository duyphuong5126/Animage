import 'package:animage/data/remote/configs_remote_data_source.dart';
import 'package:animage/domain/configs_repository.dart';

class ConfigsRepositoryImpl extends ConfigsRepository {
  late final ConfigsRemoteDataSource _remoteDataSource =
      ConfigsRemoteDataSourceImpl();

  @override
  Future<bool> isGalleryLevelingEnable() =>
      _remoteDataSource.isGalleryLevelingEnable();
}
