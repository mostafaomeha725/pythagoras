import 'package:equatable/equatable.dart';

class RegisterResponse extends Equatable {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  const RegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  @override
  List<Object?> get props => [success, message, token, user];
}
