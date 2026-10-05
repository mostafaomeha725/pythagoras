import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/auth/domain/usecases/get_whatsapp_register_url_use_case.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_state.dart';

class WhatsappRegisterCubit extends Cubit<WhatsappRegisterState> {
  final GetWhatsappRegisterUrlUseCase getWhatsappRegisterUrlUseCase;

  WhatsappRegisterCubit({required this.getWhatsappRegisterUrlUseCase})
      : super(WhatsappRegisterInitial());

  Future<void> getUrl() async {
    emit(WhatsappRegisterLoading());
    final result = await getWhatsappRegisterUrlUseCase();
    result.fold(
      (failure) => emit(WhatsappRegisterError(failure.message)),
      (url) => emit(WhatsappRegisterSuccess(url)),
    );
  }
}
