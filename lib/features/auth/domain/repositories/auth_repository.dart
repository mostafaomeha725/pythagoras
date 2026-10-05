import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String phone, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> getWhatsappRegisterUrl();
}
