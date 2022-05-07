import 'package:animage/domain/entity/artist/artist.dart';

abstract class ArtistRepository {
  Future<bool> get isArtistListChanged;

  Future<int> get artistCount;

  Future syncArtistList();

  Future<List<Artist>> getArtistList(List<int> artistIdList);

  Future<Artist?> getArtist(int artistId);
}
