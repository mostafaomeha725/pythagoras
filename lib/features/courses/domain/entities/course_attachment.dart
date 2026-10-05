class CourseAttachment {
  final String name;
  final String url;
  final String mimeType;
  final int size;
  final String? extension;

  const CourseAttachment({
    required this.name,
    required this.url,
    required this.mimeType,
    required this.size,
    this.extension,
  });
}
