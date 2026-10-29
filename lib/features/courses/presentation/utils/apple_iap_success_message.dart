import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';

String appleIapSuccessMessage({
  required bool isRestore,
  required bool alreadyEnrolled,
  required AppleIapProductType? productType,
}) {
  if (isRestore) {
    return alreadyEnrolled
        ? 'تمت استعادة المشتريات، والمحتوى متاح بالفعل'
        : 'تمت استعادة المشتريات وتفعيل المحتوى بنجاح';
  }

  return productType == AppleIapProductType.chapter
      ? 'تم شراء الحصة وتفعيلها بنجاح'
      : 'تم شراء الكورس وتفعيله بنجاح';
}
