import 'dart:async';

import 'package:animage/domain/favorite_repository.dart';
import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/artist_repository.dart';
import '../../data/configs_repository_impl.dart';
import '../../data/post_repository_impl.dart';
import '../../domain/artist_repository.dart';
import '../../domain/configs_repository.dart';
import '../../domain/entity/artist/artist.dart';
import '../../domain/entity/gallery_level.dart';
import '../../domain/entity/general/pair.dart';
import '../../domain/entity/post.dart';
import '../../domain/post_repository.dart';
import '../../domain/use_case/get_next_level_up_time_use_case.dart';
import '../../domain/use_case/temporarily_cancel_special_offer_use_case.dart';
import '../../domain/use_case/toggle_favorite_use_case.dart';
import '../../service/favorite_service.dart';
import '../ui_model/artist_ui_model.dart';
import '../ui_model/post_card_ui_model.dart';
import 'gallery_page_state.dart';

class GalleryCubit extends Cubit<GalleryPageState> {
  GalleryCubit() : super(const GalleryPageState.initial());

  late final ToggleFavoriteUseCase _toggleFavoriteUseCase =
      ToggleFavoriteUseCaseImpl();
  late final TemporarilyCancelSpecialOfferUseCase
      _temporarilyCancelSpecialOfferUseCase =
      TemporarilyCancelSpecialOfferUseCaseImpl();

  late final ArtistRepository _artistRepository = ArtistRepositoryImpl();
  late final PostRepository _postRepository = PostRepositoryImpl();
  late final ConfigsRepository _configsRepository = ConfigsRepositoryImpl();
  late final FavoriteRepository _favoriteRepository = FavoriteRepositoryImpl();

  late final GetNextLevelUpTime _getNextLevelUpTime = GetNextLevelUpTimeImpl();

  final Map<int, Post> _postDetailsMap = {};

  int _currentPage = 1;

  bool _loadingData = false;

  StreamSubscription? _loadMoreSub;

  @override
  Future<void> close() {
    _cancelLoadingSub();
    return super.close();
  }

  _cancelLoadingSub() {
    _loadMoreSub?.cancel();
    _loadMoreSub = null;
  }

  refresh() {
    _currentPage = 1;
    _cancelLoadingSub();
    emit(const GalleryPageState.initial());
    loadMore();
  }

  loadMore() async {
    if (_loadingData) {
      logD('Page $_currentPage is being loaded');
      return;
    }
    _loadingData = true;
    final pageIndex = _currentPage++;
    List<String> tagList = [];

    final currentState = state;
    if (currentState is Initialized) {
      tagList.addAll(currentState.selectedTags);
    }
    logD('fetching page $pageIndex, tagList=$tagList');
    GalleryLevel galleryLevel = await _postRepository.getGalleryLevel();
    _loadMoreSub = (tagList.isEmpty
            ? _postRepository.getPostList(pageIndex)
            : _postRepository.searchPostsByTag(tagList, pageIndex))
        .then<Pair<List<Post>, Map<int, Artist>>>((List<Post> postList) {
          if (pageIndex == 1) {
            // todo: updated at time
          }
          List<int> creatorIdList = postList
              .map((post) => post.creatorId ?? -1)
              .where((creatorId) => creatorId != -1)
              .toList();
          if (creatorIdList.isNotEmpty) {
            return _artistRepository
                .getArtists(postList)
                .then((artistMap) => Pair(first: postList, second: artistMap));
          } else {
            return Pair(first: postList, second: {});
          }
        })
        .asStream()
        .listen(
          (Pair<List<Post>, Map<int, Artist>> postsAndArtists) async {
            List<Post> postList = postsAndArtists.first;
            Map<int, Artist> artistMap = postsAndArtists.second;

            List<int> favoriteList = await _favoriteRepository
                .filterFavoriteList(postList.map((post) => post.id).toList());
            FavoriteService.addFavorites(favoriteList);

            logD('postList=${postList.length}');
            final result = postList.map((post) {
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
                logE(
                  'Could not find any artist matches id ${post.creatorId}',
                  error: error,
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

            final currentState = state;
            if (currentState is Initialized) {
              List<PostCardUiModel> finalList = [
                ...currentState.postList,
                ...result,
              ];
              emit(
                currentState.copyWith(
                  postList: finalList,
                  hasMoreData: result.isNotEmpty,
                  error: null,
                ),
              );
            } else {
              emit(
                GalleryPageState.initialized(
                  postList: List.unmodifiable(result),
                  hasMoreData: result.isNotEmpty,
                  galleryMode: GalleryMode.list,
                  galleryLevel: galleryLevel.level,
                  galleryLevelChanged: false,
                  selectedTags: {},
                ),
              );
            }
            _loadingData = false;
          },
          onError: (error, stackTrace) {
            logE('failed to get postList with error', error: error);
            final currentState = state;
            if (currentState is Initialized) {
              emit(currentState.copyWith(error: error, hasMoreData: false));
            } else {
              emit(
                GalleryPageState.initialized(
                  postList: [],
                  hasMoreData: false,
                  error: error,
                  galleryMode: GalleryMode.list,
                  galleryLevel: galleryLevel.level,
                  galleryLevelChanged: false,
                  selectedTags: {},
                ),
              );
            }
            _loadingData = false;
          },
        );
  }

  changeGalleryMode(GalleryMode mode) {
    final currentState = state;
    if (currentState is Initialized) {
      emit(currentState.copyWith(galleryMode: mode));
    }
  }

  void toggleFavorite(Post post) async {
    bool newFavoriteStatus = await _toggleFavoriteUseCase.execute(post);
    logD('New favorite status of post ${post.id}: $newFavoriteStatus');
    if (newFavoriteStatus) {
      FavoriteService.addFavorite(post.id);
    } else {
      FavoriteService.removeFavorite(post.id);
    }
  }

  void addSearchTags(Iterable<String> tags) async {
    Set<String> selectedTags = {};
    final currentState = state;
    if (currentState is Initialized) {
      selectedTags.addAll(currentState.selectedTags);

      Iterable<String> toAddList = tags
          .where((tag) => tag.isNotEmpty)
          .map((tag) => tag.trim().toLowerCase())
          .where((tag) => !selectedTags.contains(tag));

      if (toAddList.isNotEmpty) {
        emit(const GalleryPageState.initial());
        List<String> tagList = [];
        tagList.addAll(selectedTags);
        tagList.addAll(toAddList);
        selectedTags.addAll(tagList);
        emit(currentState.copyWith(selectedTags: selectedTags));
      }
    }
  }

  String specialOfferEarnedMessage(int level) {
    return 'You have access to ${level == 2 ? 'adult' : 'mature'} content now.'
        '\nIt will be active for ${GalleryLevel.levelExpirationMap[level]?.inHours ?? 0} hours.'
        '\nPlease refresh the gallery to see it.';
  }

  String specialOfferMessage(int level) {
    int requiredChallenges = GalleryLevel.levelChallengesMap[level] ?? 0;
    return requiredChallenges > 1
        ? 'Watch two ads to get access to adult content?'
        : 'Watch an ad to get access to mature content?';
  }

  void enableGalleryLevel(int level) async {
    final duration = GalleryLevel.levelExpirationMap[level] ?? const Duration();
    await _postRepository.updateGalleryLevel(level, duration);
  }

  void hideLevelUpMessageTemporarily(int level) async {
    try {
      await _temporarilyCancelSpecialOfferUseCase.execute(level);
      logD('Level up message hidden');
    } catch (e) {
      logD('Could not cancel level up message');
    }
  }

  void requestLevelChallenge() async {
    final currentState = state;
    if (currentState is! Initialized) {
      return;
    }
    bool isGalleryLevelingEnabled =
        await _configsRepository.isGalleryLevelingEnable();
    int nextGalleryLevelUpTime = await _getNextLevelUpTime.execute();
    if (isGalleryLevelingEnabled &&
        nextGalleryLevelUpTime <= DateTime.now().millisecondsSinceEpoch) {
      final postList = await _favoriteRepository.getFavoriteList(0, 20);
      GalleryLevel galleryLevel = await _postRepository.getGalleryLevel();
      if (galleryLevel.level < 2) {
        int nextLevel = galleryLevel.level + 1;
        bool levelChanged = nextLevel != currentState.galleryLevel;
        int requiredFavorites =
            GalleryLevel.levelRequiredFavoriteMap[nextLevel] ?? 0;
        if (postList.length >= requiredFavorites) {
          emit(
            currentState.copyWith(
              galleryLevel: nextLevel,
              galleryLevelChanged: levelChanged,
            ),
          );
        }
      }
    }
  }
}
