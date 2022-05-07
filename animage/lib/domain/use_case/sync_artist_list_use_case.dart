import 'package:animage/data/artist_repository.dart';
import 'package:animage/domain/artist_repository.dart';

abstract class SyncArtistListUseCase {
  Future execute();
}

class SyncArtistListUseCaseImpl extends SyncArtistListUseCase {
  final ArtistRepository _repository = ArtistRepositoryImpl();

  @override
  Future execute() => _repository.syncArtistList();
}
