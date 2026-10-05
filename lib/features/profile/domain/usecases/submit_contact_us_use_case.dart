import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';

class SubmitContactUsUseCase {
  final ProfileRepository repository;

  SubmitContactUsUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String name,
    required String email,
    required String message,
  }) async {
    return await repository.submitContactUs(
      name: name,
      email: email,
      message: message,
    );
  }
}
