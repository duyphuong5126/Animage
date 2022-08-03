import 'dart:async';

import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/domain/use_case/search_posts_by_tags_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

class NewPostsCubit extends Cubit<Iterable<String>> {
  NewPostsCubit() : super([]);

  static const int _toUpdateLength = 3;
  int _maxPostId = -1;
  Timer? updatePostTimer;

  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();
  late final SearchPostsByTagsUseCase _searchPostsByTagsUseCase =
      SearchPostsByTagsUseCaseImpl();

  final List<String> _tagList = [];

  void init(int maxPostId) {
    _maxPostId = maxPostId;
    updatePostTimer?.cancel();
    updatePostTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _updateNewPost();
    });
  }

  void updateTagsList(List<String> newTagList) async {
    if (!const DeepCollectionEquality().equals(
        newTagList.sortedBy<String>((tag) => tag),
        _tagList.sortedBy<String>((tag) => tag))) {
      _tagList.clear();
      _tagList.addAll(newTagList);
    }
  }

  void reset() {
    emit([]);
  }

  void destroy() async {
    await close();
    updatePostTimer?.cancel();
  }

  void _updateNewPost() async {
    List<Post> postList = (await (_tagList.isEmpty
            ? _getPostListUseCase.execute(1)
            : _searchPostsByTagsUseCase.execute(_tagList, 1)))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id) * -1);

    if (postList.length >= _toUpdateLength &&
        postList[_toUpdateLength - 1].id > _maxPostId) {
      Iterable<String> toUpdateList = postList
          .map((post) => post.sampleUrl ?? '')
          .where((url) => url.isNotEmpty)
          .toList()
          .sublist(0, _toUpdateLength);

      if (toUpdateList.length == _toUpdateLength) {
        emit(toUpdateList);
      }
    }
  }
}
