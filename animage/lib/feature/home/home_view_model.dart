import 'dart:io';

import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class HomeViewModel {
  void init();

  PagingController<int, PostCardUiModel> getPagingController();

  String get firstPageErrorMessage;

  String get emptyMessage;

  void destroy();
}

class HomeViewModelImpl extends HomeViewModel {
  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();

  PagingController<int, PostCardUiModel>? _pagingController;

  static const String _tag = 'HomeViewModelImpl';

  @override
  String get firstPageErrorMessage => 'Could not load library';

  @override
  String get emptyMessage => 'Empty library';

  @override
  void init() {}

  @override
  PagingController<int, PostCardUiModel> getPagingController() {
    if (_pagingController == null) {
      _pagingController = PagingController(firstPageKey: 1);
      _pagingController!.addPageRequestListener((pageKey) {
        _getPage(pageKey, _pagingController!);
      });
    }
    return _pagingController!;
  }

  Future<void> _getPage(int pageIndex,
      PagingController<int, PostCardUiModel> pagingController) async {
    Log.d(_tag, 'fetching page $pageIndex');
    _getPostListUseCase.execute(pageIndex).asStream().listen((postList) {
      Log.d(_tag, 'postList=${postList.length}');
      List<PostCardUiModel> result = postList
          .map((post) => PostCardUiModel(
              previewThumbnailUrl: post.previewUrl ?? '',
              sampleUrl: post.sampleUrl ?? '',
              author: post.author ?? ''))
          .toList();
      if (result.isEmpty) {
        pagingController.appendLastPage(result);
      } else {
        pagingController.appendPage(result, pageIndex + 1);
      }
    }, onError: (error, stackTrace) {
      Log.d(_tag, 'failed to get postList with error $error');
      pagingController.error = error;
    });
  }

  String _getErrorMessage(Error? error) {
    String errorMessage = 'Unknown error happened';
    if (error is SocketException) {
      errorMessage = 'Server timeout';
    } else if (error is FormatException) {
      errorMessage = 'Server error';
    } else if (error is IOException) {
      errorMessage = 'Request error';
    }
    return errorMessage;
  }

  @override
  void destroy() {
    _pagingController?.dispose();
    _pagingController = null;
  }
}
