import 'package:equatable/equatable.dart';

abstract class WhatsappRegisterState extends Equatable {
  const WhatsappRegisterState();

  @override
  List<Object?> get props => [];
}

class WhatsappRegisterInitial extends WhatsappRegisterState {}

class WhatsappRegisterLoading extends WhatsappRegisterState {}

class WhatsappRegisterSuccess extends WhatsappRegisterState {
  final String whatsappUrl;

  const WhatsappRegisterSuccess(this.whatsappUrl);

  @override
  List<Object?> get props => [whatsappUrl];
}

class WhatsappRegisterError extends WhatsappRegisterState {
  final String message;

  const WhatsappRegisterError(this.message);

  @override
  List<Object?> get props => [message];
}
