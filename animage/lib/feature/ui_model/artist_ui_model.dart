import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist_ui_model.freezed.dart';

@freezed
class ArtistUiModel with _$ArtistUiModel {
  const factory ArtistUiModel({
    required String name,
    required List<String> urls,
  }) = _ArtistUiModel;
}
