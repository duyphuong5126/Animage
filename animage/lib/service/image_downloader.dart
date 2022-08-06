import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/domain/entity/artist/artist.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_artist_use_case.dart';
import 'package:animage/feature/ui_model/download_state.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/service/image_down_load_state.dart';
import 'package:animage/service/notification_helper.dart';
import 'package:animage/service/notification_helper_factory.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io' show Platform;

class ImageDownloader {
  static final List<Post> _pendingList = [];
  static final DataCubit<ImageDownloadState?> downloadStateCubit =
      DataCubit(null);
  static final DataCubit<String?> pendingUrlCubit = DataCubit(null);

  static final NotificationHelper notificationHelper =
      NotificationHelperFactory.illustrationDownloadNotificationHelper;
  static final GetArtistUseCase _getArtistUseCase = GetArtistUseCaseImpl();

  static final DataCubit<Map<int, bool>>? areChildrenDownloadableCubit =
      DataCubit({});

  static final DataCubit<Set<int>> pendingIdList = DataCubit({});

  static void startDownloadingOriginalFile(Post post) async {
    ImageDownloadState? currentState = downloadStateCubit.state;
    String? fileUrl = post.fileUrl;
    if (fileUrl == null) {
      return;
    }
    if (currentState == null ||
        currentState.state == DownloadState.success ||
        currentState.state == DownloadState.failed) {
      downloadStateCubit.push(ImageDownloadState(
          postId: post.id, state: DownloadState.downloading));
      _sendDownloadInProgressNotification(post);
      Artist? artist = await _getArtistUseCase.execute(post);
      String albumName = artist != null
          ? '$appDirectoryName/${artist.name.trim().toLowerCase()}'
          : appDirectoryName;
      bool downloaded;
      try {
        downloaded =
            await GallerySaver.saveImage(fileUrl, albumName: albumName) ??
                false;
      } catch (e) {
        Log.d('ImageDownloader',
            'could not download file $fileUrl with error $e');
        downloaded = false;
      }
      downloadStateCubit.push(ImageDownloadState(
          postId: post.id,
          state: downloaded ? DownloadState.success : DownloadState.failed));
      _sendFinishDownloadNotification(post, downloaded);
      if (_pendingList.isNotEmpty) {
        Post pendingPost = _pendingList.removeAt(0);
        Set<int> newPendingList = {};
        newPendingList.addAll(pendingIdList.state);
        newPendingList.remove(pendingPost.id);
        pendingIdList.push(newPendingList);
        startDownloadingOriginalFile(pendingPost);
      }
    } else if (currentState.postId != post.id) {
      if (_pendingList
          .where((pendingPost) => pendingPost.id == post.id)
          .isEmpty) {
        _pendingList.add(post);
      }
      pendingUrlCubit.push(fileUrl);
      Set<int> newPendingList = {};
      newPendingList.addAll(pendingIdList.state);
      newPendingList.add(post.id);
      pendingIdList.push(newPendingList);
    } else {
      downloadStateCubit.push(ImageDownloadState(
          postId: post.id, state: DownloadState.downloading));
    }
  }

  static void checkChildrenDownloadable(
      int postId, Iterable<PostCardUiModel> children) async {
    Iterable<int> pendingList =
        ImageDownloader._pendingList.map((post) => post.id);
    ImageDownloadState? downloadState = downloadStateCubit.state;
    bool isAbleToDownloadChildren = children.where((child) {
      return (child.id == downloadState?.postId &&
              downloadState?.state == DownloadState.downloading) ||
          pendingList.contains(child.id);
    }).isEmpty;
    Map<int, bool> downloadableChildrenMap = {};
    downloadableChildrenMap
        .addAll(ImageDownloader.areChildrenDownloadableCubit?.state ?? {});
    downloadableChildrenMap[postId] = isAbleToDownloadChildren;
    ImageDownloader.areChildrenDownloadableCubit?.push(downloadableChildrenMap);
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
