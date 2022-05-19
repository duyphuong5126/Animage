import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/service/image_down_load_state.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ImageDownloader {
  static final List<String> _pendingList = [];
  static final DataCubit<ImageDownloadState?> downloadStateCubit =
      DataCubit(null);
  static final DataCubit<String?> pendingListCubit = DataCubit(null);

  static void startDownloading(String fileUrl) async {
    ImageDownloadState? currentState = downloadStateCubit.state;
    if (currentState == null ||
        currentState.state == DownloadState.success ||
        currentState.state == DownloadState.failed) {
      downloadStateCubit.emit(
          ImageDownloadState(url: fileUrl, state: DownloadState.downloading));
      bool downloaded =
          await GallerySaver.saveImage(fileUrl, albumName: appDirectoryName) ??
              false;
      downloadStateCubit.emit(ImageDownloadState(
          url: fileUrl,
          state: downloaded ? DownloadState.success : DownloadState.failed));
      if (_pendingList.isNotEmpty) {
        startDownloading(_pendingList.removeAt(0));
      }
    } else if (currentState.url != fileUrl) {
      if (!_pendingList.contains(fileUrl)) {
        _pendingList.add(fileUrl);
      }
      pendingListCubit.emit(fileUrl);
    } else {
      downloadStateCubit.emit(
          ImageDownloadState(url: fileUrl, state: DownloadState.downloading));
    }
  }
}
