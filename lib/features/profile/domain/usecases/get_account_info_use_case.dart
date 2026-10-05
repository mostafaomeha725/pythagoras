import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';

class GetAccountInfoUseCase {
  final ProfileRepository repository;

  GetAccountInfoUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({bool fromCache = false}) async {
    return await repository.getAccountInfo(fromCache: fromCache);
  }
}
