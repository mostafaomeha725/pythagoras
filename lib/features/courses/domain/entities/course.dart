class Course {
  final String id;
  final String title;
  final String? imageUrl;
  final double price;
  final bool isEnrolled;
  final String? level;
  final String? className;
  final int? semester;
  final String? requestStatus;
  final double? finalPrice;
  final String? currencyLabel;
  final int? studentsCount;
  final bool? isSaved;

  Course({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    this.isEnrolled = false,
    this.level,
    this.className,
    this.semester,
    this.requestStatus,
    this.finalPrice,
    this.currencyLabel,
    this.studentsCount,
    this.isSaved,
  });
}
