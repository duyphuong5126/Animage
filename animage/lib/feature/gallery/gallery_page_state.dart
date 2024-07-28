import 'package:animage/feature/ui_model/gallery_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../ui_model/post_card_ui_model.dart';

part 'gallery_page_state.freezed.dart';

@freezed
sealed class GalleryPageState with _$GalleryPageState {
  @Implements<GalleryPageInitialState>()
  const factory GalleryPageState.initial() = Initial;

  @Implements<GalleryPageInitializedState>()
  factory GalleryPageState.initialized({
    required List<PostCardUiModel> postList,
    required bool hasMoreData,
    required GalleryMode galleryMode,
    required Iterable<String> selectedTags,
    required int galleryLevel,
    @Default(false) bool galleryLevelChanged,
    Object? error,
  }) = Initialized;
}

abstract class GalleryPageInitialState implements GalleryPageState {}

abstract class GalleryPageInitializedState implements GalleryPageState {
  List<PostCardUiModel> get postList;

  Object? get error;

  bool get hasMoreData;

  GalleryMode get galleryMode;

  Iterable<String> get selectedTags;

  int get galleryLevel;

  bool get galleryLevelChanged;
}
