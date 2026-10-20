import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for Contact Us screen in Tablet Landscape mode.
/// Reuses [CourseDetailTabletTopBar] with contact us styling.
class ContactUsTabletTopBar extends StatelessWidget {
  const ContactUsTabletTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CourseDetailTabletTopBar(
      title: 'تواصل معنا',
      titleFontSize: 22,
      subtitleBadge: 'الدعم الفني والاستفسارات • متاحون لمساعدتكم',
      padding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}
