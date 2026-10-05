import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/auth/domain/usecases/logout_use_case.dart';
import 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutUseCase logoutUseCase;

  LogoutCubit(this.logoutUseCase) : super(LogoutInitial());

  Future<void> logout() async {
    // لمنع الضغط المتكرر أثناء التحميل
    if (state is LogoutLoading) return;

    emit(LogoutInitial());
    emit(LogoutLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(LogoutFailure(failure.message)),
      (_) => emit(LogoutSuccess()),
    );
  }
}
