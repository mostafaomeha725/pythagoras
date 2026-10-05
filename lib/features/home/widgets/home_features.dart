import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/home/widgets/feature_card_item.dart';

class HomeFeatures extends StatelessWidget {
  const HomeFeatures({super.key});

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
          style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return FeatureCardItem(
              icon: features[index]["icon"],
              title: features[index]["title"],
              desc: features[index]["desc"],
            );
          },
        ),
      ],
    );
  }
}
