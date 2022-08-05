import 'package:animage/feature/ui_model/download_state.dart';

class ImageDownloadState {
  final int postId;
  final String url;
  final DownloadState state;

  const ImageDownloadState(
      {required this.postId, required this.url, required this.state});
}
