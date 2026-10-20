import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for Edit Profile screen in Tablet Landscape mode.
/// Reuses [CourseDetailTabletTopBar] with profile editing styling.
class EditProfileTabletTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const EditProfileTabletTopBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return CourseDetailTabletTopBar(
      title: 'تعديل الملف الشخصي',
      titleFontSize: 21,
      subtitleBadge: 'إدارة وتحديث بيانات الحساب',
      onBack: onBack,
      padding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
