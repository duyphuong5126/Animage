import 'package:animage/data/local/artist_local_data_source.dart';
import 'package:animage/data/remote/artist_remote_data_source.dart';
import 'package:animage/domain/artist_repository.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/artist/artist_list_change_log.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/utils/log.dart';

class ArtistRepositoryImpl extends ArtistRepository {
  static const String _tag = 'ArtistRepositoryImpl';

  final ArtistRemoteDataSource _remoteDataSource = ArtistRemoteDataSourceImpl();
  final ArtistLocalDataSource _localDataSource = ArtistLocalDataSourceImpl();

  @override
  Future<bool> get isArtistListChanged {
    return _localDataSource.localVersionId
        .onError((error, stackTrace) => null)
        .then((int? localId) => _remoteDataSource
                .fetchChangeLog()
                .then((ArtistListChangeLog? remoteChangeLog) {
              Log.d(_tag, 'localId=$localId');
              if (remoteChangeLog != null &&
                  localId != remoteChangeLog.currentVersionId) {
                return _localDataSource
                    .saveChangeLog(remoteChangeLog)
                    .then((value) => true)
                    .onError((error, stackTrace) => true);
              } else {
                return false;
              }
            }));
  }

  @override
  Future<int> get artistCount => _localDataSource.artistCount;

  @override
  Future syncArtistList() {
    return _remoteDataSource.fetchArtistList().then((remoteList) {
      Log.d(_tag, 'remoteList=${remoteList.length}');
      return _localDataSource.insertArtist(remoteList);
    });
  }

  @override
  Future<Map<int, Artist>> getArtists(List<Post> postList) =>
      _localDataSource.getArtists(postList);

  @override
  Future<Artist?> getArtist(Post post) =>
      _localDataSource.getArtist(post);
}
