import 'dart:async';

import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/get_post_list_use_case.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewPostCubit extends Cubit<Iterable<String>> {
  NewPostCubit() : super([]);

  static const int _toUpdateLength = 1;
  int _maxPostId = -1;
  Timer? updatePostTimer;

  late final GetPostListUseCase _getPostListUseCase = GetPostListUseCaseImpl();

  void init(int maxPostId) {
    _maxPostId = maxPostId;
    updatePostTimer?.cancel();
    updatePostTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      Log.d("Test>>>", 'Updating new posts');
      List<Post> postList = (await _getPostListUseCase.execute(1)).toList()
        ..sort((a, b) => a.id.compareTo(b.id) * -1);

      if (postList.length >= _toUpdateLength &&
          postList[_toUpdateLength - 1].id >= _maxPostId) {
        Iterable<String> toUpdateList = postList
            .map((post) => post.sampleUrl ?? '')
            .where((url) => url.isNotEmpty)
            .toList()
            .sublist(0, _toUpdateLength);

        if (toUpdateList.length == _toUpdateLength) {
          emit(toUpdateList);
        }
      }
    });
  }

  void reset() {
    emit([]);
  }

  void destroy() async {
    Log.d('Test>>>', 'destroy');
    await close();
    updatePostTimer?.cancel();
  }
}
