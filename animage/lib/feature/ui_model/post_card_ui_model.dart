import 'package:animage/feature/ui_model/artist_ui_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/post.dart';

part 'post_card_ui_model.freezed.dart';

@freezed
class PostCardUiModel with _$PostCardUiModel {
  factory PostCardUiModel({
    required int id,
    required String author,
    required String previewThumbnailUrl,
    required double previewAspectRatio,
    required String sampleUrl,
    required double sampleAspectRatio,
    ArtistUiModel? artist,

    required Post post,
  }) = _PostCardUiModel;
}
