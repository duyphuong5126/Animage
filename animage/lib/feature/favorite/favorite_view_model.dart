import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/general/pair.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_artists_use_case.dart';
import 'package:animage/domain/use_case/get_favorite_list_use_case.dart';
import 'package:animage/domain/use_case/toggle_favorite_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/utils/log.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

abstract class FavoriteViewModel {
  DataCubit<Post?> get postDetailsCubit;

  String pageTitle(int favoriteCount);

  String get firstPageErrorMessage;

  String get emptyMessage;

  void init();

  PagingController<int, PostCardUiModel> getPagingController();

  void requestDetailsPage(int postId);

  void clearDetailsPageRequest();

  void refreshGallery();

  void toggleFavorite(PostCardUiModel uiModel);

  void destroy();

  // For iOS only
  DataCubit<int> get galleryRefreshedAtCubit;

  String get refreshingText;

  String get failedToRefreshText;

  String get refreshedSuccessfullyText;

  String get refresherIdleText;

  String get refresherReleaseText;

  String get defaultTitle;
}

class FavoriteViewModelImpl extends FavoriteViewModel {
  static const int _pageSize = 25;
  static const String _tag = 'FavoriteViewModelImpl';
  static const String _defaultTitle = 'Favorite';

  DataCubit<Post?>? _postDetailsCubit;
  DataCubit<int>? _galleryRefreshedAtCubit;

  final Map<int, Post> _postDetailsMap = {};

  PagingController<int, PostCardUiModel>? _pagingController;

  final GetFavoriteListUseCase _getFavoriteListUseCase =
      GetFavoriteListUseCaseImpl();
  final GetArtistsUseCase _getArtistsUseCase = GetArtistListUseCaseImpl();
  final ToggleFavoriteUseCase _toggleFavoriteUseCase =
      ToggleFavoriteUseCaseImpl();

  @override
  DataCubit<int> get galleryRefreshedAtCubit => _galleryRefreshedAtCubit!;

  @override
  DataCubit<Post?> get postDetailsCubit => _postDetailsCubit!;

  @override
  String get emptyMessage => 'Empty library';

  @override
  String get failedToRefreshText => 'Unable to refresh gallery';

  @override
  String get firstPageErrorMessage => 'Could not load library';

  @override
  String pageTitle(int favoriteCount) {
    NumberFormat numberFormat = NumberFormat('###,###');
    return favoriteCount > 0
        ? '$_defaultTitle (${numberFormat.format(favoriteCount)})'
        : _defaultTitle;
  }

  @override
  String get refreshedSuccessfullyText => 'Refreshed';

  @override
  String get refresherIdleText => 'Pull down';

  @override
  String get refresherReleaseText => 'Release to refresh';

  @override
  String get refreshingText => 'Refreshing gallery';

  @override
  String get defaultTitle => _defaultTitle;

  @override
  void clearDetailsPageRequest() {
    _postDetailsCubit?.push(null);
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
  void init() {
    _postDetailsCubit = DataCubit(null);
    _galleryRefreshedAtCubit = DataCubit(-1);
  }

  @override
  void refreshGallery() {
    _pagingController?.refresh();
  }

  @override
  void requestDetailsPage(int postId) {
    Post? matchedPost = _postDetailsMap[postId];
    if (matchedPost != null) {
      _postDetailsCubit?.push(matchedPost);
    }
  }

  @override
  void destroy() {
    _postDetailsCubit?.closeAsync();
    _postDetailsCubit = null;
    _galleryRefreshedAtCubit?.closeAsync();
    _galleryRefreshedAtCubit = null;
  }

  @override
  void toggleFavorite(PostCardUiModel uiModel) async {
    Post? post = _postDetailsMap[uiModel.id];
    if (post != null) {
      bool newFavoriteStatus = await _toggleFavoriteUseCase.execute(post);
      Log.d(_tag, 'New favorite status of post ${post.id}: $newFavoriteStatus');
      if (newFavoriteStatus) {
        FavoriteService.addFavorite(uiModel.id);
      } else {
        FavoriteService.removeFavorite(uiModel.id);
      }
    }
  }

  Future<void> _getPage(
    int pageIndex,
    PagingController<int, PostCardUiModel> pagingController,
  ) async {
    _getFavoriteListUseCase
        .execute((pageIndex - 1) * _pageSize, _pageSize)
        .then<Pair<List<Post>, Map<int, Artist>>>((List<Post> postList) {
          if (pageIndex == 1) {
            _galleryRefreshedAtCubit
                ?.push(DateTime.now().millisecondsSinceEpoch);
          }
          List<int> creatorIdList = postList
              .map((post) => post.creatorId ?? -1)
              .where((creatorId) => creatorId != -1)
              .toList();
          if (creatorIdList.isNotEmpty) {
            return _getArtistsUseCase
                .execute(postList)
                .then((artistMap) => Pair(first: postList, second: artistMap));
          } else {
            return Pair(first: postList, second: {});
          }
        })
        .asStream()
        .listen((Pair<List<Post>, Map<int, Artist>> postsAndArtists) async {
          List<Post> postList = postsAndArtists.first;
          Map<int, Artist> artistMap = postsAndArtists.second;

          FavoriteService.addFavorites(postList.map((post) => post.id));

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
              Artist? artist = artistMap[post.id];
              if (artist != null) {
                artistUiModel =
                    ArtistUiModel(name: artist.name, urls: artist.urls);
              }
            } catch (error) {
              Log.d(
                _tag,
                'Could not find any artist matches id ${post.creatorId}',
              );
            }

            return PostCardUiModel(
              id: post.id,
              author: post.author ?? '',
              previewThumbnailUrl: post.previewUrl ?? '',
              previewAspectRatio: previewAspectRatio,
              sampleUrl: post.sampleUrl ?? '',
              sampleAspectRatio: sampleAspectRatio,
              artist: artistUiModel,
              post: post,
            );
          }).toList();
          Log.d(_tag, 'result=${result.length}');
          if (result.isEmpty) {
            pagingController.appendLastPage(result);
          } else {
            pagingController.appendPage(result, pageIndex + 1);
          }
        }, onError: (error, stackTrace) {
          Log.d(_tag, 'failed to get postList with error: $error');
          pagingController.error = error;
        });
  }
}
