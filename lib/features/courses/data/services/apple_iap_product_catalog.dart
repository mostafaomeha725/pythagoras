enum AppleIapProductType { course, chapter }

class AppleIapProductTarget {
  final AppleIapProductType type;
  final int contentId;

  const AppleIapProductTarget({required this.type, required this.contentId});
}

class AppleIapProductCatalog {
  const AppleIapProductCatalog._();

  // Temporary mapping until course data provides apple_product_id.
  static const Map<String, AppleIapProductTarget> products = {
    'pythagoras.course.21': AppleIapProductTarget(
      type: AppleIapProductType.course,
      contentId: 21,
    ),
    'pythagoras.course.29': AppleIapProductTarget(
      type: AppleIapProductType.course,
      contentId: 29,
    ),
  };

  static Set<String> get productIds => products.keys.toSet();

  static bool hasProductFor(AppleIapProductType type, int contentId) {
    return products.values.any(
      (target) => target.type == type && target.contentId == contentId,
    );
  }

  static AppleIapProductTarget? targetFor(String productId) =>
      products[productId];
}
