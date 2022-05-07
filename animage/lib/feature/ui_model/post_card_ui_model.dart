import 'package:animage/feature/ui_model/artist_ui_model.dart';

class PostCardUiModel {
  final int id;
  final ArtistUiModel? artist;

  final String previewThumbnailUrl;
  final double previewAspectRatio;
  final String sampleUrl;
  final double sampleAspectRatio;

  final String author;

  const PostCardUiModel(
      {required this.id,
      required this.author,
      required this.previewThumbnailUrl,
      required this.previewAspectRatio,
      required this.sampleUrl,
      required this.sampleAspectRatio,
      this.artist});
}
