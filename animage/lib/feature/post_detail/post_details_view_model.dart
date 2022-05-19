import 'dart:async';

import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_artist_use_case.dart';
import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:animage/service/image_downloader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';

abstract class PostDetailsViewModel {
  DataCubit<Color> get sampleImageDominantColorCubit;

  DataCubit<ArtistUiModel?> get artistCubit;

  void initData(Post post);

  String getCreatedAtTimeStamp(Post post);

  String getUpdatedAtTimeStamp(Post post);

  String getRatingLabel(Post post);

  void startDownloadingOriginalImage(Post post);

  void destroy();
}

class PostDetailsViewModelImpl extends PostDetailsViewModel {
  final DataCubit<Color> _sampleImageDominantColorCubit =
      DataCubit(Colors.white);

  final DataCubit<ArtistUiModel?> _artistCubit = DataCubit(null);

  final GetArtistUseCase _getArtistUseCase = GetArtistUseCaseImpl();

  StreamSubscription? _getArtistSubscription;

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
      ImageDownloader.startDownloading(fileUrl);
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
        _sampleImageDominantColorCubit.emit(dominantColor);
      }
    }
  }

  @override
  void destroy() async {
    await _getArtistSubscription?.cancel();
  }

  void _initArtist(Post post) async {
    _getArtistSubscription =
        _getArtistUseCase.execute(post).asStream().listen((artist) {
      if (artist != null) {
        _artistCubit.emit(ArtistUiModel(name: artist.name, urls: artist.urls));
      }
    });
  }
}
