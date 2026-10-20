import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/home/widgets/home_tablet_feature_card.dart';

/// 3-column features row optimized for Tablet Landscape.
class HomeTabletFeatures extends StatelessWidget {
  const HomeTabletFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        "icon": "💰",
        "title": "الدفع حسب الفصل",
        "desc": "ادفع فقط مقابل الفصول التي تحتاجها – مرن وملائم للطلاب.",
      },
      {
        "icon": "📝",
        "title": "واجبات تفاعلية",
        "desc": "مارس ما تعلمته بعد كل درس مع تمارين مصممة خصيصًا لك.",
      },
      {
        "icon": "🎯",
        "title": "اختبارات وتقييم ذاتي",
        "desc": "اختبر فهمك من خلال اختبارات سريعة لتتبع تقدمك الدراسي.",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "مميزات التعلم الذكي",
          style: font18w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 680) {
              return Column(
                children: features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HomeTabletFeatureCard(feature: feature),
                  );
                }).toList(),
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: features.map((feature) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: HomeTabletFeatureCard(feature: feature),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
