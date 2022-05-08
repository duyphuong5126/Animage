import 'package:animage/data/artist_repository.dart';
import 'package:animage/domain/artist_repository.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/post.dart';

abstract class GetArtistsUseCase {
  Future<Map<int, Artist>> execute(List<Post> postList);
}

class GetArtistListUseCaseImpl extends GetArtistsUseCase {
  final ArtistRepository _repository = ArtistRepositoryImpl();

  @override
  Future<Map<int, Artist>> execute(List<Post> postList) =>
      _repository.getArtists(postList);
}
