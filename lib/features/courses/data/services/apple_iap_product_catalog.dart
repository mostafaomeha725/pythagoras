enum AppleIapProductType { course, chapter }

class AppleIapProductTarget {
  final AppleIapProductType type;
  final int contentId;

  const AppleIapProductTarget({required this.type, required this.contentId});
}

class AppleIapProductCatalog {
  const AppleIapProductCatalog._();

  static const Map<String, AppleIapProductTarget> products = {
    'pythagoras.course.21': AppleIapProductTarget(
      type: AppleIapProductType.course,
      contentId: 21,
    ),
  };

  static Set<String> get productIds => products.keys.toSet();

  static AppleIapProductTarget? targetFor(String productId) =>
      products[productId];
}
