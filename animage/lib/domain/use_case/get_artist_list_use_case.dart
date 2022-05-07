import 'package:animage/data/artist_repository.dart';
import 'package:animage/domain/artist_repository.dart';
import 'package:animage/domain/entity/artist/artist.dart';

abstract class GetArtistListUseCase {
  Future<List<Artist>> execute(List<int> artistIdList);
}

class GetArtistListUseCaseImpl extends GetArtistListUseCase {
  final ArtistRepository _repository = ArtistRepositoryImpl();

  @override
  Future<List<Artist>> execute(List<int> artistIdList) =>
      _repository.getArtistList(artistIdList);
}
