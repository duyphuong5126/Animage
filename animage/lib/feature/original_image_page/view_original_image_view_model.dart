import 'package:animage/bloc/data_cubit.dart';

abstract class ViewOriginalViewModel {
  DataCubit<String> get galleryTitle;

  void onGalleryItemSelected(int position, int itemCount);

  void destroy();
}

class ViewOriginalViewModelImpl extends ViewOriginalViewModel {
  final DataCubit<String> _galleryTitle = DataCubit('');

  @override
  void onGalleryItemSelected(int position, int itemCount) {
    _galleryTitle.push(itemCount > 1 && position + 1 <= itemCount
        ? '${position + 1}/$itemCount'
        : '');
  }

  @override
  DataCubit<String> get galleryTitle => _galleryTitle;

  @override
  void destroy() {
    _galleryTitle.closeAsync();
  }
}
