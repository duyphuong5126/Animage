import 'dart:async';

import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewPostsCubit extends Cubit<Iterable<String>> {
  NewPostsCubit() : super([]);

  static const int _toUpdateLength = 3;
  int _maxPostId = -1;
  Timer? updatePostTimer;

  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();

  void init(int maxPostId) {
    _maxPostId = maxPostId;
    updatePostTimer?.cancel();
    updatePostTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _updateNewPost();
    });
  }

  void reset() {
    emit([]);
  }

  void destroy() async {
    await close();
    updatePostTimer?.cancel();
  }

  void _updateNewPost() async {
    List<Post> postList = (await _getPostListUseCase.execute(1)).toList()
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
