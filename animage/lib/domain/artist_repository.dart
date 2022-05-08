import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/post.dart';

abstract class ArtistRepository {
  Future<bool> get isArtistListChanged;

  Future<int> get artistCount;

  Future syncArtistList();

  Future<Map<int, Artist>> getArtists(List<Post> postList);

  Future<Artist?> getArtist(Post post);
}
