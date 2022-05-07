import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/general/pair.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_artist_list_use_case.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class HomeViewModel {
  DataCubit<Post?> get postDetailsCubit;

  DataCubit<int> get buildGalleryCubit;

  String get firstPageErrorMessage;

  String get emptyMessage;

  void init();

  PagingController<int, PostCardUiModel> getPagingController();

  void requestDetailsPage(int postId);

  void clearDetailsPageRequest();

  void rebuildGallery();

  void destroy();
}

class HomeViewModelImpl extends HomeViewModel {
  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();
  late final GetArtistListUseCase _getArtistListUseCase =
      GetArtistListUseCaseImpl();

  PagingController<int, PostCardUiModel>? _pagingController;

  DataCubit<Post?>? _postDetailsCubit;

  DataCubit<int>? _buildGalleryCubit;

  final Map<int, Post> _postDetailsMap = {};

  static const String _tag = 'HomeViewModelImpl';

  @override
  DataCubit<Post?> get postDetailsCubit => _postDetailsCubit!;

  @override
  DataCubit<int> get buildGalleryCubit => _buildGalleryCubit!;

  @override
  String get firstPageErrorMessage => 'Could not load library';

  @override
  String get emptyMessage => 'Empty library';

  @override
  void init() {
    Log.d(_tag, 'init');
    _postDetailsCubit = DataCubit(null);
    _buildGalleryCubit = DataCubit(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  PagingController<int, PostCardUiModel> getPagingController() {
    if (_pagingController == null) {
      _pagingController = PagingController(firstPageKey: 1);
      _pagingController!.addPageRequestListener((pageKey) {
        _getPage(pageKey, _pagingController!);
      });
    }
    return _pagingController!;
  }

  @override
  void requestDetailsPage(int postId) {
    Post? matchedPost = _postDetailsMap[postId];
    if (matchedPost != null) {
      _postDetailsCubit?.emit(matchedPost);
    }
  }

  @override
  void clearDetailsPageRequest() {
    _postDetailsCubit?.emit(null);
  }

  @override
  void rebuildGallery() {
    _buildGalleryCubit?.emit(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void destroy() {
    Log.d(_tag, 'destroy');
    _pagingController?.dispose();
    _pagingController = null;
    _postDetailsCubit?.closeAsync();
    _postDetailsCubit = null;
    _buildGalleryCubit?.closeAsync();
    _buildGalleryCubit = null;
  }

  Future<void> _getPage(int pageIndex,
      PagingController<int, PostCardUiModel> pagingController) async {
    Log.d(_tag, 'fetching page $pageIndex');
    _getPostListUseCase
        .execute(pageIndex)
        .then<Pair<List<Post>, List<Artist>>>((List<Post> postList) {
          List<int> creatorIdList = postList
              .map((post) => post.creatorId ?? -1)
              .where((creatorId) => creatorId != -1)
              .toList();
          if (creatorIdList.isNotEmpty) {
            return _getArtistListUseCase.execute(creatorIdList).then(
                (artistList) => Pair(first: postList, second: artistList));
          } else {
            return Pair(first: postList, second: []);
          }
        })
        .asStream()
        .listen((Pair<List<Post>, List<Artist>> postsAndArtists) {
          List<Post> postList = postsAndArtists.first;
          List<Artist> artistList = postsAndArtists.second;

          Log.d(_tag, 'postList=${postList.length}');
          List<PostCardUiModel> result = postList.map((post) {
            _postDetailsMap[post.id] = post;
            int sampleWidth = post.sampleWidth ?? 0;
            int sampleHeight = post.sampleHeight ?? 0;
            double sampleAspectRatio = sampleWidth > 0 && sampleHeight > 0
                ? sampleWidth.toDouble() / sampleHeight
                : 1;
            int previewWidth = post.previewWidth ?? 0;
            int previewHeight = post.previewHeight ?? 0;
            double previewAspectRatio = previewWidth > 0 && previewHeight > 0
                ? previewWidth.toDouble() / previewHeight
                : 1;

            ArtistUiModel? artistUiModel;
            try {
              Artist artist = artistList
                  .firstWhere((artistData) => artistData.id == post.creatorId);
              artistUiModel =
                  ArtistUiModel(name: artist.name, urls: artist.urls);
            } catch (error) {
              Log.d(_tag,
                  'Could not find any artist matches id ${post.creatorId}');
            }

            return PostCardUiModel(
                id: post.id,
                author: post.author ?? '',
                previewThumbnailUrl: post.previewUrl ?? '',
                previewAspectRatio: previewAspectRatio,
                sampleUrl: post.sampleUrl ?? '',
                sampleAspectRatio: sampleAspectRatio,
                artist: artistUiModel);
          }).toList();
          if (result.isEmpty) {
            pagingController.appendLastPage(result);
          } else {
            pagingController.appendPage(result, pageIndex + 1);
          }
        }, onError: (error, stackTrace) {
          Log.d(_tag, 'failed to get postList with error $error');
          pagingController.error = error;
        });
  }
}
