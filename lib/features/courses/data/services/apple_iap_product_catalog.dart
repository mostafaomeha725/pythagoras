enum AppleIapProductType { course, chapter }

class AppleIapProductTarget {
  final AppleIapProductType type;
  final int contentId;
  final int? parentContentId;

  const AppleIapProductTarget({
    required this.type,
    required this.contentId,
    this.parentContentId,
  });
}
