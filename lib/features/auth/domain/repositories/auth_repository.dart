import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/auth/domain/entities/register_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String phone, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> getWhatsappRegisterUrl();
  Future<Either<Failure, RegisterResponse>> register({
    required String name,
    required String phone,
    required String password,
    required int classId,
    String type = 'student',
  });
}
