import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/feature/ui_model/post_card_ui_model.dart';
import 'package:animage/utils/log.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class HomeViewModel {
  DataCubit<Post?> get postDetailsCubit;

  String get firstPageErrorMessage;

  String get emptyMessage;

  void init();

  PagingController<int, PostCardUiModel> getPagingController();

  void requestDetailsPage(int postId);

  void clearDetailsPageRequest();

  void destroy();
}

class HomeViewModelImpl extends HomeViewModel {
  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();

  PagingController<int, PostCardUiModel>? _pagingController;

  DataCubit<Post?>? _postDetailsCubit;

  final Map<int, Post> _postDetailsMap = {};

  static const String _tag = 'HomeViewModelImpl';

  @override
  DataCubit<Post?> get postDetailsCubit => _postDetailsCubit!;

  @override
  String get firstPageErrorMessage => 'Could not load library';

  @override
  String get emptyMessage => 'Empty library';

  @override
  void init() {
    Log.d(_tag, 'init');
    _postDetailsCubit = DataCubit(null);
  }

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

  @override
  void requestDetailsPage(int postId) {
    Post? matchedPost = _postDetailsMap[postId];
    if (matchedPost != null) {
      _postDetailsCubit?.emit(matchedPost);
    }
  }

  @override
  void clearDetailsPageRequest() {
    _postDetailsCubit?.emit(null);
  }

  @override
  void destroy() {
    Log.d(_tag, 'destroy');
    _pagingController?.dispose();
    _pagingController = null;
    _postDetailsCubit?.closeAsync();
    _postDetailsCubit = null;
  }

  Future<void> _getPage(int pageIndex,
      PagingController<int, PostCardUiModel> pagingController) async {
    Log.d(_tag, 'fetching page $pageIndex');
    _getPostListUseCase.execute(pageIndex).asStream().listen((postList) {
      Log.d(_tag, 'postList=${postList.length}');
      List<PostCardUiModel> result = postList.map((post) {
        _postDetailsMap[post.id] = post;
        int sampleWidth = post.sampleWidth ?? 0;
        int sampleHeight = post.sampleHeight ?? 0;
        double sampleAspectRatio = sampleWidth > 0 && sampleHeight > 0
            ? sampleWidth.toDouble() / sampleHeight
            : 1;
        int previewWidth = post.previewWidth ?? 0;
        int previewHeight = post.previewHeight ?? 0;
        double previewAspectRatio = previewWidth > 0 && previewHeight > 0
            ? previewWidth.toDouble() / previewHeight
            : 1;
        return PostCardUiModel(
            id: post.id,
            author: post.author ?? '',
            previewThumbnailUrl: post.previewUrl ?? '',
            previewAspectRatio: previewAspectRatio,
            sampleUrl: post.sampleUrl ?? '',
            sampleAspectRatio: sampleAspectRatio);
      }).toList();
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
}
