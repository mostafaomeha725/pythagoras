import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pythagoras/core/services/remote_config_service.dart';
import 'remote_config_state.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  final RemoteConfigService remoteConfigService;
  Future<void>? _loadFuture;
  StreamSubscription<bool>? _updatesSubscription;
  StreamSubscription<bool>? _courseLessonRequestsSubscription;

  RemoteConfigCubit({required this.remoteConfigService})
    : super(const RemoteConfigState());

  Future<void> load() {
    return _loadFuture ??= _load();
  }

  Future<void> _load() async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      await remoteConfigService.initialize();
      if (isClosed) return;
      _updatesSubscription ??= remoteConfigService.iosIapEnabledChanges.listen(
        _emitIapState,
        onError: (Object error, StackTrace stackTrace) =>
            _emitIapState(false, errorMessage: error.toString()),
      );
      _courseLessonRequestsSubscription ??= remoteConfigService
          .courseLessonRequestsEnabledChanges
          .listen(
            _emitCourseLessonRequestsState,
            onError: (Object error, StackTrace stackTrace) =>
                _emitCourseLessonRequestsState(
                  remoteConfigService.courseLessonRequestsEnabled,
                ),
          );
      emit(
        state.copyWith(
          iosIapEnabled: remoteConfigService.iosIapEnabled,
          courseLessonRequestsEnabled:
              remoteConfigService.courseLessonRequestsEnabled,
          isLoading: false,
        ),
      );
      debugPrint(
        '[IAP][RemoteConfigCubit] iosIapEnabled=${remoteConfigService.iosIapEnabled}',
      );
    } catch (error) {
      if (isClosed) return;
      debugPrint('[IAP][RemoteConfigCubit] error=$error');
      emit(
        state.copyWith(
          iosIapEnabled: false,
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _emitIapState(bool enabled, {String? errorMessage}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        iosIapEnabled: enabled,
        isLoading: false,
        errorMessage: errorMessage,
        clearErrorMessage: errorMessage == null,
      ),
    );
  }

  void _emitCourseLessonRequestsState(bool enabled) {
    if (isClosed) return;
    emit(
      state.copyWith(courseLessonRequestsEnabled: enabled, isLoading: false),
    );
  }

  @override
  Future<void> close() async {
    await _updatesSubscription?.cancel();
    await _courseLessonRequestsSubscription?.cancel();
    return super.close();
  }
}
