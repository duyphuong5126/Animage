import 'package:animage/data/artist_repository.dart';
import 'package:animage/domain/artist_repository.dart';

abstract class CheckArtistListChangedUseCase {
  Future<bool> execute();
}

class CheckArtistListChangedUseCaseImpl extends CheckArtistListChangedUseCase {
  final ArtistRepository _repository = ArtistRepositoryImpl();

  @override
  Future<bool> execute() => _repository.isArtistListChanged;
}
