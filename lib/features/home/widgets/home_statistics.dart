import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/home/widgets/stat_card_item.dart';

class HomeStatistics extends StatelessWidget {
  const HomeStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        "icon": "👥",
        "value": "+1,000",
        "label": "طالب تعلم مع فيثاغورس",
        "bgColor": const Color(0xFFE0F2FE), // Light blue
      },
      {
        "icon": "🎓",
        "value": "+80",
        "label": "درس للمرحلة الثانوية",
        "bgColor": const Color(0xFFFEF3C7), // Light yellow
      },
      {
        "icon": "⭐",
        "value": "95%",
        "label": "رضا الطلاب",
        "bgColor": const Color(0xFFFCEEFA), // Light pink/purple
      },
      {
        "icon": "📝",
        "value": "+80",
        "label": "دروس وتمارين",
        "bgColor": const Color(0xFFECFDF5), // Light green
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "إحصائيات المنصة",
          style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.1,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return StatCardItem(
              icon: stats[index]["icon"],
              value: stats[index]["value"],
              label: stats[index]["label"],
              bgColor: stats[index]["bgColor"],
            );
          },
        ),
      ],
    );
  }
}
