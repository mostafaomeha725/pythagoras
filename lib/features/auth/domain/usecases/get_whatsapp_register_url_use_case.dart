import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';

class GetWhatsappRegisterUrlUseCase {
  final AuthRepository repository;

  GetWhatsappRegisterUrlUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getWhatsappRegisterUrl();
  }
}
