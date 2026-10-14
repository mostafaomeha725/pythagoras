import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import '../entities/user_profile.dart';

import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getAccountInfo({bool fromCache = false});
  Future<Either<Failure, String>> uploadProfilePicture(File image);
  Future<Either<Failure, UserProfile>> updatePersonalProfile({required String name, String? password});
  Future<Either<Failure, List<MyCourseEnrollment>>> getMyCourses({bool fromCache = false});
  Future<Either<Failure, String>> submitContactUs({required String name, required String email, required String message});
  Future<Either<Failure, void>> deleteAccount();
}
