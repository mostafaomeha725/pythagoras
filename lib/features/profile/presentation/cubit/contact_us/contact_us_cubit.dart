import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/domain/usecases/submit_contact_us_use_case.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_state.dart';

class ContactUsCubit extends Cubit<ContactUsState> {
  final SubmitContactUsUseCase submitContactUsUseCase;

  ContactUsCubit({required this.submitContactUsUseCase}) : super(ContactUsInitial());

  Future<void> submit({
    required String name,
    required String email,
    required String message,
  }) async {
    emit(ContactUsLoading());

    final result = await submitContactUsUseCase(
      name: name,
      email: email,
      message: message,
    );

    result.fold(
      (failure) => emit(ContactUsError(failure.message)),
      (successMessage) => emit(ContactUsSuccess(successMessage)),
    );
  }
}
