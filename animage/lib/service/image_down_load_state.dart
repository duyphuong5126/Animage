import 'package:animage/feature/ui_model/download_state.dart';

class ImageDownloadState {
  final String url;
  final DownloadState state;

  const ImageDownloadState({required this.url, required this.state});
}
