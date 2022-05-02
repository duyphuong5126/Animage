class PostCardUiModel {
  final String previewThumbnailUrl;
  final double previewAspectRatio;
  final String sampleUrl;
  final double sampleAspectRatio;

  final String author;

  const PostCardUiModel(
      {required this.author,
      required this.previewThumbnailUrl,
      required this.previewAspectRatio,
      required this.sampleUrl,
      required this.sampleAspectRatio});
}
