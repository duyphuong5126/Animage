import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';

abstract class PostDetailsViewModel {
  DataCubit<Color> get sampleImageDominantColorCubit;

  void initData(Post post);

  String getCreatedAtTimeStamp(Post post);

  String getUpdatedAtTimeStamp(Post post);

  String getRatingLabel(Post post);
}

class PostDetailsViewModelImpl extends PostDetailsViewModel {
  final DataCubit<Color> _sampleImageDominantColorCubit =
      DataCubit(Colors.white);

  @override
  DataCubit<Color> get sampleImageDominantColorCubit =>
      _sampleImageDominantColorCubit;

  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initData(Post post) async {
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
}
