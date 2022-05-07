import 'package:animage/data/artist_repository.dart';
import 'package:animage/domain/artist_repository.dart';
import 'package:animage/domain/entity/artist/artist.dart';

abstract class GetArtistUseCase {
  Future<Artist?> execute(int artistId);
}

class GetArtistUseCaseImpl extends GetArtistUseCase {
  final ArtistRepository _repository = ArtistRepositoryImpl();

  @override
  Future<Artist?> execute(int artistId) => _repository.getArtist(artistId);
}
