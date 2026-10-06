import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/domain/usecases/get_account_info_use_case.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetAccountInfoUseCase getAccountInfoUseCase;
  bool _isFetchingRemote = false;

  ProfileCubit(this.getAccountInfoUseCase) : super(ProfileInitial());

  Future<void> getAccountInfo() async {
    // 1. Load from cache first
    final cacheResult = await getAccountInfoUseCase(fromCache: true);
    cacheResult.fold(
      (failure) {
        if (state is! ProfileLoaded && !isClosed) {
          emit(ProfileLoading());
        }
      },
      (cachedProfile) {
        if (isClosed) return;
        emit(ProfileLoaded(cachedProfile));
      },
    );

    if (_isFetchingRemote || isClosed) return;
    _isFetchingRemote = true;

    // 2. Fetch from remote in background
    final result = await getAccountInfoUseCase(fromCache: false);
    
    _isFetchingRemote = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (state is! ProfileLoaded) {
          final isSessionExpired = failure.message == 'SESSION_EXPIRED';
          emit(ProfileFailure(
            isSessionExpired ? 'انتهت صلاحية الجلسة' : failure.message,
            isSessionExpired: isSessionExpired,
          ));
        }
      },
      (userProfile) {
        emit(ProfileLoaded(userProfile));
      },
    );
  }

  void resetProfile() {
    emit(ProfileInitial());
  }
}
