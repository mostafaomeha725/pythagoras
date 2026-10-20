import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';

class UpdatePersonalProfileUseCase {
  final ProfileRepository repository;

  UpdatePersonalProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required String name,
    String? password,
  }) {
    return repository.updatePersonalProfile(name: name, password: password);
  }
}
