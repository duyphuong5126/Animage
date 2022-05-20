import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/service/image_down_load_state.dart';
import 'package:animage/service/notification_helper.dart';
import 'package:animage/service/notification_helper_factory.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io' show Platform;

class ImageDownloader {
  static final List<Post> _pendingList = [];
  static final DataCubit<ImageDownloadState?> downloadStateCubit =
      DataCubit(null);
  static final DataCubit<String?> pendingListCubit = DataCubit(null);

  static final NotificationHelper notificationHelper =
      NotificationHelperFactory.illustrationDownloadNotificationHelper;

  static void startDownloadingOriginalFile(Post post) async {
    ImageDownloadState? currentState = downloadStateCubit.state;
    String? fileUrl = post.fileUrl;
    if (fileUrl == null) {
      return;
    }
    if (currentState == null ||
        currentState.state == DownloadState.success ||
        currentState.state == DownloadState.failed) {
      downloadStateCubit.emit(
          ImageDownloadState(url: fileUrl, state: DownloadState.downloading));
      _sendDownloadInProgressNotification(post);
      bool downloaded =
          await GallerySaver.saveImage(fileUrl, albumName: appDirectoryName) ??
              false;
      downloadStateCubit.emit(ImageDownloadState(
          url: fileUrl,
          state: downloaded ? DownloadState.success : DownloadState.failed));
      _sendFinishDownloadNotification(post, downloaded);
      if (_pendingList.isNotEmpty) {
        startDownloadingOriginalFile(_pendingList.removeAt(0));
      }
    } else if (currentState.url != fileUrl) {
      if (_pendingList
          .where((pendingPost) => pendingPost.id == post.id)
          .isEmpty) {
        _pendingList.add(post);
      }
      pendingListCubit.emit(fileUrl);
    } else {
      downloadStateCubit.emit(
          ImageDownloadState(url: fileUrl, state: DownloadState.downloading));
    }
  }

  static void _sendDownloadInProgressNotification(Post post) {
    if (Platform.isIOS) {
      notificationHelper.sendIOSNotification(
          post.id,
          'Downloading Illustration',
          'Downloading original file of post ${post.id}',
          presentAlert: true,
          presentSound: true,
          presentBadge: true);
    } else if (Platform.isAndroid) {
      notificationHelper.sendAndroidProgressNotification(
          post.id,
          'Downloading Illustration',
          'Downloading original file of post ${post.id}',
          styleInformation: const BigTextStyleInformation(''));
    }
  }

  static void _sendFinishDownloadNotification(Post post, bool downloaded) {
    String title = downloaded ? 'Download Success' : 'Download Failed';
    String message = downloaded
        ? 'Original illustration of post ${post.id} is downloaded'
        : 'Could not download the original illustration of post ${post.id}';
    if (Platform.isIOS) {
      notificationHelper.sendIOSNotification(post.id, title, message,
          presentAlert: true, presentSound: true, presentBadge: true);
    } else if (Platform.isAndroid) {
      notificationHelper.sendAndroidNotification(post.id, title, message);
    }
  }
}
