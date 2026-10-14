import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/domain/usecases/delete_account_use_case.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final DeleteAccountUseCase deleteAccountUseCase;

  DeleteAccountCubit(this.deleteAccountUseCase) : super(DeleteAccountInitial());

  Future<void> deleteAccount() async {
    if (state is DeleteAccountLoading) return;

    emit(DeleteAccountInitial());
    emit(DeleteAccountLoading());

    final result = await deleteAccountUseCase();

    result.fold(
      (failure) => emit(DeleteAccountFailure(failure.message)),
      (_) => emit(DeleteAccountSuccess()),
    );
  }
}
