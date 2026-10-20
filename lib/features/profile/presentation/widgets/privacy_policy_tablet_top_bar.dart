import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for Privacy Policy screen in Tablet Landscape mode.
/// Reuses [CourseDetailTabletTopBar] with privacy policy styling.
class PrivacyPolicyTabletTopBar extends StatelessWidget {
  const PrivacyPolicyTabletTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CourseDetailTabletTopBar(
      title: 'سياسة الخصوصية',
      titleFontSize: 21,
      subtitleBadge: 'أمان وحماية بيانات المستخدم • الامتثال للوائح الدولية',
      padding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}
