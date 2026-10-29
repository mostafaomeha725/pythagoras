import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_result.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class VerifyApplePurchaseUseCase {
  final CoursesRepository repository;

  VerifyApplePurchaseUseCase(this.repository);

  Future<ApplePurchaseVerificationResult> call(String signedTransaction) {
    return repository.verifyApplePurchase(signedTransaction);
  }
}
