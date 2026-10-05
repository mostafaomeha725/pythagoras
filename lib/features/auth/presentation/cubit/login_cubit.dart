import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/utils/validators.dart';
import 'package:pythagoras/features/auth/domain/usecases/login_use_case.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit(this.loginUseCase) : super(LoginInitial());

  Future<void> login(String phone, String password) async {
    final phoneError = Validators.phone(phone);
    if (phoneError != null) {
      emit(LoginInitial());
      emit(LoginFailure(phoneError));
      return;
    }

    final passwordError = Validators.password(
      password,
      emptyMessage: 'يرجى إدخال كلمة المرور',
    );
    if (passwordError != null) {
      emit(LoginInitial());
      emit(LoginFailure(passwordError));
      return;
    }

    emit(LoginLoading());

    final result = await loginUseCase(phone, password);

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginSuccess()),
    );
  }
}
