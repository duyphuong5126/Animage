import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/general/pair.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/filter_favorite_list_use_case.dart';
import 'package:animage/domain/use_case/get_artist_use_case.dart';
import 'package:animage/domain/use_case/get_artists_use_case.dart';
import 'package:animage/domain/use_case/search_posts_by_tags_use_case.dart';
import 'package:animage/domain/use_case/toggle_favorite_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/feature/ui_model/view_original_ui_model.dart';
import 'package:animage/service/favorite_service.dart';
import 'package:animage/service/image_downloader.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';

abstract class PostDetailsViewModel {
  DataCubit<Post?> get postDetailsCubit;

  DataCubit<ViewOriginalUiModel?> get vieOriginalPostsCubit;

  DataCubit<List<PostCardUiModel>> get childrenCubit;

  DataCubit<Color> get sampleImageDominantColorCubit;

  DataCubit<ArtistUiModel?> get artistCubit;

  String get tagSectionTitle;

  String get downloadOnHoldTitle;

  String get downloadOnHoldMessage;

  String get downloadOnHoldAction;

  String get downloadChildrenTitle;

  String get downloadChildrenAction;

  String get acceptDownloadChildrenAction;

  String get cancelDownloadChildrenAction;

  String get downloadSuccessTitle;

  String get downloadSuccessMessage;

  String get downloadFailureTitle;

  String get downloadFailureMessage;

  String get downloadResultAction;

  void initData(Post post);

  String getCreatedAtTimeStamp(Post post);

  String getUpdatedAtTimeStamp(Post post);

  String getRatingLabel(Post post);

  String getStatusLabel(Post post);

  String getSourceLabel(Post post);

  String getScoreLabel(Post post);

  String getArtistLabel(ArtistUiModel? artistUiModel);

  String getArtistInfo(List<String> urls);

  String getChildrenSectionTitle(int childCount);

  String getDownloadChildrenMessage(int childCount);

  void requestDetailsPage(int postId);

  void requestViewOriginal(Post post);

  void clearViewOriginalRequest();

  void clearDetailsPageRequest();

  void startDownloadAllChildren(int postId, List<PostCardUiModel> children);

  void toggleFavorite(Post post);

  void toggleFavoriteOfPost(int postId);

  void startDownloadingOriginalImage(Post post);

  void destroy();
}

class PostDetailsViewModelImpl extends PostDetailsViewModel {
  static const String _tag = 'PostDetailsViewModelImpl';

  final DataCubit<Color> _sampleImageDominantColorCubit =
      DataCubit(Colors.white);
  final DataCubit<Post?>? _postDetailsCubit = DataCubit(null);
  final DataCubit<ViewOriginalUiModel?>? _viewOriginalUiModelCubit =
      DataCubit(null);
  final DataCubit<List<PostCardUiModel>>? _childrenCubit = DataCubit([]);

  PagingController<int, PostCardUiModel>? _pagingController;

  final DataCubit<ArtistUiModel?> _artistCubit = DataCubit(null);

  final GetArtistUseCase _getArtistUseCase = GetArtistUseCaseImpl();
  final ToggleFavoriteUseCase _toggleFavoriteUseCase =
      ToggleFavoriteUseCaseImpl();
  final FilterFavoriteListUseCase _filterFavoriteListUseCase =
      FilterFavoriteListUseCaseImpl();
  final SearchPostsByTagsUseCase _searchPostsByTagsUseCase =
      SearchPostsByTagsUseCaseImpl();
  final GetArtistsUseCase _getArtistsUseCase = GetArtistListUseCaseImpl();

  StreamSubscription? _getArtistSubscription;
  StreamSubscription? _initFavoriteSubscription;
  StreamSubscription? _downloadStateSubscription;

  final Map<int, Post> _postDetailsMap = {};

  @override
  DataCubit<Post?> get postDetailsCubit => _postDetailsCubit!;

  @override
  DataCubit<ViewOriginalUiModel?> get vieOriginalPostsCubit =>
      _viewOriginalUiModelCubit!;

  @override
  DataCubit<List<PostCardUiModel>> get childrenCubit => _childrenCubit!;

  @override
  DataCubit<Color> get sampleImageDominantColorCubit =>
      _sampleImageDominantColorCubit;

  @override
  DataCubit<ArtistUiModel?> get artistCubit => _artistCubit;

  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initData(Post post) async {
    _initArtist(post);
    _initColorPalette(post);
    _initChildren(post.id);
    _initFavoriteSubscription = _filterFavoriteListUseCase
        .execute([post.id])
        .asStream()
        .listen((favoriteList) {
          FavoriteService.addFavorites(favoriteList);
        });

    _downloadStateSubscription = ImageDownloader.downloadStateCubit.stream
        .listen((downloadState) => ImageDownloader.checkChildrenDownloadable(
            post.id, _childrenCubit?.state ?? []));
  }

  @override
  String getCreatedAtTimeStamp(Post post) {
    int? createdAt = post.createdAt;
    return createdAt != null
        ? 'Created at: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000))}'
        : '';
  }

  @override
  String getUpdatedAtTimeStamp(Post post) {
    int? updatedAt = post.updatedAt;
    return updatedAt != null
        ? 'Updated at: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000))}'
        : '';
  }

  @override
  String getRatingLabel(Post post) {
    String ratingString = post.rating != null ? post.rating!.toLowerCase() : '';
    if (ratingString == 's') {
      return 'Rating: Safe';
    } else if (ratingString == 'q') {
      return 'Rating: Questionable';
    } else if (ratingString == 'e') {
      return 'Rating: Explicit';
    } else {
      return 'Rating: Unknown';
    }
  }

  @override
  void startDownloadingOriginalImage(Post post) {
    String? fileUrl = post.fileUrl;
    if (fileUrl != null && fileUrl.isNotEmpty) {
      ImageDownloader.startDownloadingOriginalFile(post);
    }
  }

  void _initColorPalette(Post post) async {
    String? sampleUrl = post.sampleUrl;
    if (sampleUrl != null && sampleUrl.isNotEmpty) {
      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        Image.network(sampleUrl).image,
      );
      Color? dominantColor = paletteGenerator.dominantColor?.color;
      if (dominantColor != null) {
        _sampleImageDominantColorCubit.push(dominantColor);
      }
    }
  }

  @override
  void toggleFavorite(Post post) async {
    bool newFavoriteStatus = await _toggleFavoriteUseCase.execute(post);
    Log.d(_tag, 'New favorite status of post ${post.id}: $newFavoriteStatus');
    if (newFavoriteStatus) {
      FavoriteService.addFavorite(post.id);
    } else {
      FavoriteService.removeFavorite(post.id);
    }
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
  void startDownloadAllChildren(
      int postId, List<PostCardUiModel> children) async {
    List<int> childIds = children.map((child) => child.id).toList();
    childIds.sort((int idA, int idB) => idA.compareTo(idB));
    for (int childId in childIds) {
      Post? childPost = _postDetailsMap[childId];
      if (childPost != null) {
        ImageDownloader.startDownloadingOriginalFile(childPost);
      }
    }
    ImageDownloader.checkChildrenDownloadable(
        postId, _childrenCubit?.state ?? []);
  }

  @override
  void destroy() async {
    await _getArtistSubscription?.cancel();
    _initFavoriteSubscription?.cancel();
    _initFavoriteSubscription = null;
    _pagingController?.dispose();
    _pagingController = null;
    _postDetailsCubit?.closeAsync();
    _downloadStateSubscription?.cancel();
  }

  void _initArtist(Post post) async {
    _getArtistSubscription =
        _getArtistUseCase.execute(post).asStream().listen((artist) {
      if (artist != null) {
        _artistCubit.push(ArtistUiModel(name: artist.name, urls: artist.urls));
      }
    });
  }

  Future<void> _initChildren(int postId) async {
    _searchPostsByTagsUseCase
        .execute(['parent:$postId'], 1)
        .then((children) =>
            children.where((child) => child.id != postId).toList())
        .then<Pair<List<Post>, Map<int, Artist>>>((List<Post> postList) {
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
          if (result.isNotEmpty) {
            _childrenCubit?.push(result);
          }
        }, onError: (error, stackTrace) {
          Log.d(_tag,
              'Could not find any children of this post with error $error');
        });
  }

  @override
  String get tagSectionTitle => 'Tags: ';

  @override
  String get downloadOnHoldAction => 'OK';

  @override
  String get downloadOnHoldMessage =>
      'This post is added to pending list. Please wait.';

  @override
  String get downloadOnHoldTitle => 'Download On Hold';

  @override
  String get downloadChildrenTitle => 'Download Children';

  @override
  String get acceptDownloadChildrenAction => 'Yes';

  @override
  String get cancelDownloadChildrenAction => 'No';

  @override
  String get downloadChildrenAction => 'Download All';

  @override
  String get downloadFailureMessage =>
      'Could not download original illustration.';

  @override
  String get downloadFailureTitle => 'Download Failed';

  @override
  String get downloadSuccessMessage => 'Original illustration is downloaded.';

  @override
  String get downloadSuccessTitle => 'Download Success';

  @override
  String get downloadResultAction => 'OK';

  @override
  String getStatusLabel(Post post) {
    return 'Status: ${post.status}';
  }

  @override
  String getSourceLabel(Post post) {
    return 'Source: ${post.status}';
  }

  @override
  String getScoreLabel(Post post) {
    return 'Score: ${post.score}';
  }

  @override
  String getArtistInfo(List<String> urls) {
    return 'Artist info: ${urls.join('\n')}';
  }

  @override
  String getChildrenSectionTitle(int childCount) {
    return 'Children ($childCount)';
  }

  @override
  String getDownloadChildrenMessage(int childCount) {
    return 'You are about to download $childCount child posts,\n do you want to proceed?';
  }

  @override
  String getArtistLabel(ArtistUiModel? artistUiModel) {
    return artistUiModel?.name ?? 'Unknown artist';
  }

  @override
  void toggleFavoriteOfPost(int postId) async {
    Post? post = _postDetailsMap[postId];
    if (post != null) {
      bool newFavoriteStatus = await _toggleFavoriteUseCase.execute(post);
      Log.d(_tag, 'New favorite status of post ${post.id}: $newFavoriteStatus');
      if (newFavoriteStatus) {
        FavoriteService.addFavorite(post.id);
      } else {
        FavoriteService.removeFavorite(post.id);
      }
    }
  }

  @override
  void requestViewOriginal(Post post) {
    List<Post> viewOriginalList = [];
    viewOriginalList.add(post);
    List<PostCardUiModel> children = _childrenCubit?.state ?? [];
    for (PostCardUiModel child in children) {
      Post? childPost = _postDetailsMap[child.id];
      if (childPost != null) {
        viewOriginalList.add(childPost);
      }
    }
    viewOriginalList.sort((Post a, Post b) => a.id.compareTo(b.id));
    _viewOriginalUiModelCubit
        ?.push(ViewOriginalUiModel(posts: viewOriginalList));
  }

  @override
  void clearViewOriginalRequest() {
    _viewOriginalUiModelCubit?.push(null);
  }
}
