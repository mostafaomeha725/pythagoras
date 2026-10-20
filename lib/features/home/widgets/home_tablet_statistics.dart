import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/home/widgets/home_tablet_stat_card.dart';

/// 4-column statistics row optimized for Tablet Landscape.
class HomeTabletStatistics extends StatelessWidget {
  const HomeTabletStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        "icon": "👥",
        "value": "+1,000",
        "label": "طالب تعلم مع فيثاغورس",
        "bgColor": const Color(0xFFE0F2FE),
      },
      {
        "icon": "🎓",
        "value": "+80",
        "label": "درس للمرحلة الثانوية",
        "bgColor": const Color(0xFFFEF3C7),
      },
      {
        "icon": "⭐",
        "value": "95%",
        "label": "رضا الطلاب",
        "bgColor": const Color(0xFFFCEEFA),
      },
      {
        "icon": "📝",
        "value": "+80",
        "label": "دروس وتمارين",
        "bgColor": const Color(0xFFECFDF5),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "إحصائيات المنصة",
          style: font18w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 650) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: stats
                    .map((item) => HomeTabletStatCard(item: item))
                    .toList(),
              );
            }
            return Row(
              children: stats.map((item) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: HomeTabletStatCard(item: item),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
