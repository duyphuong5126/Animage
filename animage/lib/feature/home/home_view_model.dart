import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/general/pair.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_artists_use_case.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/domain/use_case/search_posts_by_tags_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class HomeViewModel {
  DataCubit<Post?> get postDetailsCubit;

  DataCubit<List<String>> get tagListCubit;

  String get pageTitle;

  String get firstPageErrorMessage;

  String get emptyMessage;

  void init();

  PagingController<int, PostCardUiModel> getPagingController();

  void requestDetailsPage(int postId);

  void clearDetailsPageRequest();

  void refreshGallery();

  void addSearchTag(String tag);

  void removeSearchTag(String tag);

  void destroy();

  // For iOS only
  DataCubit<int> get galleryRefreshedAtCubit;

  String get cancelSearchButtonLabel;

  String get refreshingText;

  String get failedToRefreshText;

  String get refreshedSuccessfullyText;

  String get refresherIdleText;

  String get refresherReleaseText;
}

class HomeViewModelImpl extends HomeViewModel {
  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();
  late final GetArtistsUseCase _getArtistsUseCase = GetArtistListUseCaseImpl();
  late final SearchPostsByTagsUseCase _searchPostsByTagsUseCase =
      SearchPostsByTagsUseCaseImpl();

  PagingController<int, PostCardUiModel>? _pagingController;

  DataCubit<Post?>? _postDetailsCubit;
  DataCubit<int>? _galleryRefreshedAtCubit;
  DataCubit<List<String>>? _tagListCubit;

  final Map<int, Post> _postDetailsMap = {};

  static const String _tag = 'HomeViewModelImpl';

  @override
  DataCubit<Post?> get postDetailsCubit => _postDetailsCubit!;

  @override
  DataCubit<int> get galleryRefreshedAtCubit => _galleryRefreshedAtCubit!;

  @override
  DataCubit<List<String>> get tagListCubit => _tagListCubit!;

  @override
  String get pageTitle => 'Illustrations';

  @override
  String get firstPageErrorMessage => 'Could not load library';

  @override
  String get emptyMessage => 'Empty library';

  @override
  String get cancelSearchButtonLabel => 'Cancel';

  @override
  String get refreshingText => 'Refreshing gallery';

  @override
  String get failedToRefreshText => 'Unable to refresh gallery';

  @override
  String get refreshedSuccessfullyText => 'Refreshed';

  @override
  String get refresherIdleText => 'Pull down';

  @override
  String get refresherReleaseText => 'Release to refresh';

  @override
  void init() {
    Log.d(_tag, 'init');
    _postDetailsCubit = DataCubit(null);
    _galleryRefreshedAtCubit = DataCubit(-1);
    _tagListCubit = DataCubit([]);
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
  void refreshGallery() {
    _pagingController?.refresh();
  }

  @override
  void addSearchTag(String tag) {
    if (tag.isNotEmpty) {
      String normalizedSearchTag = tag.trim().toLowerCase();
      List<String> currentTagList = _tagListCubit?.state ?? [];
      if (currentTagList.contains(normalizedSearchTag)) {
        return;
      }
      List<String> tagList = [];
      tagList.addAll(currentTagList);
      tagList.add(normalizedSearchTag);
      _tagListCubit?.emit(tagList);
      _pagingController?.refresh();
    }
  }

  @override
  void removeSearchTag(String tag) {
    if (tag.isNotEmpty) {
      String normalizedSearchTag = tag.trim().toLowerCase();
      List<String> currentTagList = _tagListCubit?.state ?? [];
      if (!currentTagList.contains(normalizedSearchTag)) {
        return;
      }
      currentTagList.remove(normalizedSearchTag);
      List<String> tagList = [];
      tagList.addAll(currentTagList);
      _tagListCubit?.emit(tagList);
      _pagingController?.refresh();
    }
  }

  @override
  void destroy() {
    Log.d(_tag, 'destroy');
    _pagingController?.dispose();
    _pagingController = null;
    _postDetailsCubit?.closeAsync();
    _postDetailsCubit = null;
    _galleryRefreshedAtCubit?.closeAsync();
    _galleryRefreshedAtCubit = null;
    _tagListCubit?.closeAsync();
    _tagListCubit = null;
  }

  Future<void> _getPage(int pageIndex,
      PagingController<int, PostCardUiModel> pagingController) async {
    Log.d(_tag, 'fetching page $pageIndex');
    List<String> tagList = _tagListCubit?.state ?? [];
    (tagList.isEmpty
            ? _getPostListUseCase.execute(pageIndex)
            : _searchPostsByTagsUseCase.execute(tagList, pageIndex))
        .then<Pair<List<Post>, Map<int, Artist>>>((List<Post> postList) {
          if (pageIndex == 1) {
            _galleryRefreshedAtCubit
                ?.emit(DateTime.now().millisecondsSinceEpoch);
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
        .listen((Pair<List<Post>, Map<int, Artist>> postsAndArtists) {
          List<Post> postList = postsAndArtists.first;
          Map<int, Artist> artistMap = postsAndArtists.second;

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
              Artist? artist = artistMap[post.id];
              if (artist != null) {
                artistUiModel =
                    ArtistUiModel(name: artist.name, urls: artist.urls);
              }
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
          Log.d(_tag, 'failed to get postList with error: $error');
          pagingController.error = error;
        });
  }
}
