class CourseDetailInstructor {
  final int id;
  final String name;
  final String title;
  final String major;
  final String bio;
  final String? image;

  const CourseDetailInstructor({
    required this.id,
    required this.name,
    required this.title,
    required this.major,
    required this.bio,
    this.image,
  });
}
