import 'dart:async';

import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entity/gallery_level.dart';
import '../../domain/post_repository.dart';
import '../../domain/use_case/get_gallery_level_use_case.dart';

part 'setting_cubit.freezed.dart';

@freezed
sealed class SettingState with _$SettingState {
  const factory SettingState.initial() = SettingInitialState;

  const factory SettingState.initialized({
    required String appName,
    required String appVersion,
    required int galleryLevel,
    DateTime? galleryLevelExpirationTime,
  }) = SettingInitializedState;
}

const _logTag = 'SettingCubit';

class SettingCubit extends Cubit<SettingState> {
  final GetGalleryLevelUseCase _galleryLevelUseCase =
      GetGalleryLevelUseCaseImpl();

  final PostRepository _postRepository = PostRepositoryImpl();

  SettingCubit() : super(const SettingState.initial());

  StreamSubscription? _levelSubscription;

  init() async {
    DateTime? galleryLevelExpirationTime;

    GalleryLevel galleryLevel = await _galleryLevelUseCase.execute();

    if (galleryLevel.level > 0) {
      galleryLevelExpirationTime =
          DateTime.fromMillisecondsSinceEpoch(galleryLevel.expirationTime);
    }

    final packageInfo = await PackageInfo.fromPlatform();

    emit(
      SettingState.initialized(
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        galleryLevel: galleryLevel.level,
        galleryLevelExpirationTime: galleryLevelExpirationTime,
      ),
    );

    _levelSubscription = (await _postRepository.observeGalleryLevel()).listen(
      (galleryLevel) {
        Log.d(
          _logTag,
          'galleryLevel=${galleryLevel.level}, expiration=${galleryLevel.expirationTime}',
        );
        final currentState = state;
        if (currentState is SettingInitializedState) {
          emit(
            currentState.copyWith(
              galleryLevel: galleryLevel.level,
              galleryLevelExpirationTime: DateTime.fromMillisecondsSinceEpoch(
                galleryLevel.expirationTime,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> close() {
    _levelSubscription?.cancel();
    _levelSubscription = null;
    return super.close();
  }
}
