import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/filter_favorite_list_use_case.dart';
import 'package:animage/domain/use_case/get_artist_use_case.dart';
import 'package:animage/domain/use_case/toggle_favorite_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/service/image_downloader.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';

abstract class PostDetailsViewModel {
  DataCubit<Color> get sampleImageDominantColorCubit;

  DataCubit<ArtistUiModel?> get artistCubit;

  DataCubit<bool> get favoriteStateCubit;

  void initData(Post post);

  String getCreatedAtTimeStamp(Post post);

  String getUpdatedAtTimeStamp(Post post);

  String getRatingLabel(Post post);

  void toggleFavorite(Post post, bool isFavorite);

  void startDownloadingOriginalImage(Post post);

  void destroy();
}

class PostDetailsViewModelImpl extends PostDetailsViewModel {
  static const String _tag = 'PostDetailsViewModelImpl';

  final DataCubit<Color> _sampleImageDominantColorCubit =
      DataCubit(Colors.white);

  final DataCubit<ArtistUiModel?> _artistCubit = DataCubit(null);
  final DataCubit<bool> _favoriteInitStateCubit = DataCubit(false);

  final GetArtistUseCase _getArtistUseCase = GetArtistUseCaseImpl();
  final ToggleFavoriteUseCase _toggleFavoriteUseCase =
      ToggleFavoriteUseCaseImpl();
  final FilterFavoriteListUseCase _filterFavoriteListUseCase =
      FilterFavoriteListUseCaseImpl();

  StreamSubscription? _getArtistSubscription;
  StreamSubscription? _initFavoriteSubscription;

  @override
  DataCubit<Color> get sampleImageDominantColorCubit =>
      _sampleImageDominantColorCubit;

  @override
  DataCubit<ArtistUiModel?> get artistCubit => _artistCubit;

  @override
  DataCubit<bool> get favoriteStateCubit => _favoriteInitStateCubit;

  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initData(Post post) async {
    _initArtist(post);
    _initColorPalette(post);
    _initFavoriteSubscription = _filterFavoriteListUseCase
        .execute([post.id])
        .asStream()
        .listen((favoriteList) {
          _favoriteInitStateCubit.push(favoriteList.isNotEmpty);
        });
  }

  @override
  String getCreatedAtTimeStamp(Post post) {
    int? createdAt = post.createdAt;
    return createdAt != null
        ? formatter
            .format(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000))
        : '';
  }

  @override
  String getUpdatedAtTimeStamp(Post post) {
    int? updatedAt = post.updatedAt;
    return updatedAt != null
        ? formatter
            .format(DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000))
        : '';
  }

  @override
  String getRatingLabel(Post post) {
    String ratingString = post.rating != null ? post.rating!.toLowerCase() : '';
    if (ratingString == 's') {
      return 'Safe';
    } else if (ratingString == 'q') {
      return 'Questionable';
    } else if (ratingString == 'e') {
      return 'Explicit';
    } else {
      return 'Unknown';
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
  void toggleFavorite(Post post, bool isFavorite) async {
    bool success = await _toggleFavoriteUseCase.execute(post);
    Log.d(_tag, 'Toggle favorite success: $success');
    if (success) {
      _favoriteInitStateCubit.push(!isFavorite);
    }
  }

  @override
  void destroy() async {
    await _getArtistSubscription?.cancel();
    _initFavoriteSubscription?.cancel();
    _initFavoriteSubscription = null;
  }

  void _initArtist(Post post) async {
    _getArtistSubscription =
        _getArtistUseCase.execute(post).asStream().listen((artist) {
      if (artist != null) {
        _artistCubit.push(ArtistUiModel(name: artist.name, urls: artist.urls));
      }
    });
  }
}
