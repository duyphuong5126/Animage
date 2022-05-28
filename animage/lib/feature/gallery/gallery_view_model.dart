import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/general/pair.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/add_search_filter_use_case.dart';
import 'package:animage/domain/use_case/delete_search_filter_use_case.dart';
import 'package:animage/domain/use_case/filter_favorite_list_use_case.dart';
import 'package:animage/domain/use_case/get_all_search_filters_use_case.dart';
import 'package:animage/domain/use_case/get_artists_use_case.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/domain/use_case/search_posts_by_tags_use_case.dart';
import 'package:animage/domain/use_case/toggle_favorite_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/utils/log.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class GalleryViewModel {
  DataCubit<Post?> get postDetailsCubit;

  DataCubit<List<String>> get tagListCubit;

  DataCubit<bool> get setUpFinishCubit;

  String get pageTitle;

  String get firstPageErrorMessage;

  String get emptyMessage;

  String get removeTagTitle;

  String get acceptTagRemoval;

  String get cancelTagRemoval;

  String getTagRemovalMessage(String tag);

  void init();

  PagingController<int, PostCardUiModel> getPagingController();

  void requestDetailsPage(int postId);

  void clearDetailsPageRequest();

  void refreshGallery();

  void addSearchTag(String tag);

  void addSearchTags(Iterable<String> tags);

  void removeSearchTag(String tag);

  void toggleFavorite(PostCardUiModel uiModel);

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

class GalleryViewModelImpl extends GalleryViewModel {
  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();
  late final GetArtistsUseCase _getArtistsUseCase = GetArtistListUseCaseImpl();
  late final SearchPostsByTagsUseCase _searchPostsByTagsUseCase =
      SearchPostsByTagsUseCaseImpl();
  late final GetAllSearchFiltersUseCase _getAllSearchHistoryUseCase =
      GetAllSearchFiltersUseCaseImpl();
  late final AddSearchFilterUseCase _addSearchTermUseCase =
      AddSearchFilterUseCaseImpl();
  late final DeleteSearchFilterUseCase _deleteSearchTermUseCase =
      DeleteSearchFilterUseCaseImpl();
  late final ToggleFavoriteUseCase _toggleFavoriteUseCase =
      ToggleFavoriteUseCaseImpl();
  late final FilterFavoriteListUseCase _filterFavoriteListUseCase =
      FilterFavoriteListUseCaseImpl();

  late final StreamSubscription? _getAllSearchHistorySubscription;

  PagingController<int, PostCardUiModel>? _pagingController;

  DataCubit<Post?>? _postDetailsCubit;
  DataCubit<int>? _galleryRefreshedAtCubit;
  DataCubit<List<String>>? _tagListCubit;
  DataCubit<bool>? _setUpFinishCubit;

  final Map<int, Post> _postDetailsMap = {};

  static const String _tag = 'GalleryViewModelImpl';

  @override
  DataCubit<Post?> get postDetailsCubit => _postDetailsCubit!;

  @override
  DataCubit<int> get galleryRefreshedAtCubit => _galleryRefreshedAtCubit!;

  @override
  DataCubit<List<String>> get tagListCubit => _tagListCubit!;

  @override
  DataCubit<bool> get setUpFinishCubit => _setUpFinishCubit!;

  @override
  String get pageTitle => 'Illustrations';

  @override
  String get firstPageErrorMessage => 'Could not load library';

  @override
  String get emptyMessage => 'Empty library';

  @override
  String get cancelSearchButtonLabel => 'Cancel';

  @override
  String get acceptTagRemoval => 'Yes';

  @override
  String get cancelTagRemoval => 'No';

  @override
  String getTagRemovalMessage(String tag) => 'Remove this tag: $tag?';

  @override
  String get removeTagTitle => 'Remove Tag';

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
    _setUpFinishCubit = DataCubit(false);

    _getAllSearchHistorySubscription = _getAllSearchHistoryUseCase
        .execute()
        .asStream()
        .listen((searchHistory) {
      _tagListCubit?.push(searchHistory);
      _setUpFinishCubit?.push(true);
    });
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
      _postDetailsCubit?.push(matchedPost);
    }
  }

  @override
  void clearDetailsPageRequest() {
    _postDetailsCubit?.push(null);
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
      _tagListCubit?.push(tagList);
      _pagingController?.refresh();
      _addSearchTag(normalizedSearchTag);
    }
  }

  void _addSearchTag(String tag) async {
    bool addResult = await _addSearchTermUseCase.execute(
        tag, DateTime.now().millisecondsSinceEpoch);
    Log.d(_tag, 'Add result of tag $tag: $addResult');
  }

  void _addSearchTags(Iterable<String> tags) async {
    for (String tag in tags) {
      bool addResult = await _addSearchTermUseCase.execute(
          tag, DateTime.now().millisecondsSinceEpoch);
      Log.d(_tag, 'Add result of tag $tag: $addResult');
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
      _tagListCubit?.push(tagList);
      _pagingController?.refresh();
      _removeSearchTag(normalizedSearchTag);
    }
  }

  void _removeSearchTag(String tag) async {
    bool removeResult = await _deleteSearchTermUseCase.execute(tag);
    Log.d(_tag, 'Remove result of tag $tag: $removeResult');
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
    _getAllSearchHistorySubscription?.cancel();
    _getAllSearchHistorySubscription = null;
  }

  Future<void> _getPage(int pageIndex,
      PagingController<int, PostCardUiModel> pagingController) async {
    List<String> tagList = _tagListCubit?.state ?? [];
    Log.d(_tag, 'fetching page $pageIndex, tagList=$tagList');
    (tagList.isEmpty
            ? _getPostListUseCase.execute(pageIndex)
            : _searchPostsByTagsUseCase.execute(tagList, pageIndex))
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

          List<int> favoriteList = await _filterFavoriteListUseCase
              .execute(postList.map((post) => post.id).toList());
          FavoriteService.addFavorites(favoriteList);

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
              artist: artistUiModel,
            );
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

  @override
  void addSearchTags(Iterable<String> tags) {
    List<String> currentTagList = _tagListCubit?.state ?? [];
    Iterable<String> toAddList = tags
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => !currentTagList.contains(tag));
    if (toAddList.isNotEmpty) {
      List<String> tagList = [];
      tagList.addAll(currentTagList);
      tagList.addAll(toAddList);
      _tagListCubit?.push(tagList);
      _pagingController?.refresh();
      _addSearchTags(toAddList);
    }
  }
}
