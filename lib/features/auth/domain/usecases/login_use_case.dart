import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, void>> call(String phone, String password) async {
    return await repository.login(phone, password);
  }
}
