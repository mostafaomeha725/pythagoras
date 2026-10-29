import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_diagnostic.dart';

class VerifyApplePurchaseUseCase {
  final CoursesRepository repository;

  VerifyApplePurchaseUseCase(this.repository);

  Future<ApplePurchaseVerificationDiagnostic> call(String signedTransaction) {
    return repository.verifyApplePurchase(signedTransaction);
  }
}
