import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';

class UploadProfilePictureUseCase {
  final ProfileRepository repository;

  UploadProfilePictureUseCase(this.repository);

  Future<Either<Failure, String>> call(File image) async {
    return await repository.uploadProfilePicture(image);
  }
}
