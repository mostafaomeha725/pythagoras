import 'package:pythagoras/core/constants/app_assets.dart';

class CourseSection {
  final String label;
  final String assetPath;

  const CourseSection({required this.label, required this.assetPath});

  static const List<CourseSection> defaultSections = [
    CourseSection(label: 'الدروس المسجلة', assetPath: Assets.lesson),
    CourseSection(label: 'الإمتحانات والواجبات', assetPath: Assets.exam),
    CourseSection(label: 'الحصص الأونلاين', assetPath: Assets.online),
    CourseSection(label: 'الموارد', assetPath: Assets.files),
  ];
}
