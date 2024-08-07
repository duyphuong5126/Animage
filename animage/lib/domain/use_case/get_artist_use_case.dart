import 'package:animage/data/artist_repository.dart';
import 'package:animage/domain/artist_repository.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/post.dart';

abstract class GetArtistUseCase {
  Future<Artist?> execute(Post post);
}

class GetArtistUseCaseImpl extends GetArtistUseCase {
  final ArtistRepository _repository = ArtistRepositoryImpl();

  @override
  Future<Artist?> execute(Post post) => _repository.getArtist(post);
}
