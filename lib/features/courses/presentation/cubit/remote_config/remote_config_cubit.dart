import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pythagoras/core/services/remote_config_service.dart';
import 'remote_config_state.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  final RemoteConfigService remoteConfigService;
  Future<void>? _loadFuture;
  StreamSubscription<bool>? _updatesSubscription;

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
        _emitFeatureState,
        onError: (Object error, StackTrace stackTrace) =>
            _emitFeatureState(false, errorMessage: error.toString()),
      );
      emit(
        state.copyWith(
          iosIapEnabled: remoteConfigService.iosIapEnabled,
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

  void _emitFeatureState(bool enabled, {String? errorMessage}) {
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

  @override
  Future<void> close() async {
    await _updatesSubscription?.cancel();
    return super.close();
  }
}
