import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/auth/domain/entities/register_response.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, RegisterResponse>> call({
    required String name,
    required String phone,
    required String password,
    required int classId,
    String type = 'student',
  }) {
    return repository.register(
      name: name,
      phone: phone,
      password: password,
      classId: classId,
      type: type,
    );
  }
}
