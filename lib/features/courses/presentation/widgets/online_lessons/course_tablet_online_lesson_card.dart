import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';

/// Online lesson card component optimized for Tablet Landscape.
/// Uses explicit typography and paddings without ScreenUtil scaling.
class CourseTabletOnlineLessonCard extends StatelessWidget {
  final OnlineLesson lesson;

  const CourseTabletOnlineLessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isLive = lesson.status == OnlineLessonStatus.live;
    final borderColor =
        isLive ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB);
    final pillBgColor =
        isLive ? const Color(0xFFFEF2F2) : const Color(0xFFFDF4FA);
    final pillTextColor =
        isLive ? const Color(0xFFEF4444) : AppLightColors.primary;
    final pillText = isLive ? 'مباشر الآن' : 'قادمة';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title + Subject + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: AppText(
                            lesson.title,
                            style: font16w700.copyWith(
                              color: const Color(0xFF1E1E2D),
                              fontSize: 15,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      lesson.subject,
                      style: font12w700.copyWith(
                        color: AppLightColors.primary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  pillText,
                  style: font12w700.copyWith(
                    color: pillTextColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date & Time details
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 5),
                  AppText(
                    lesson.dateString,
                    style: font12w500.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 5),
                  AppText(
                    lesson.timeString,
                    style: font12w500.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions Row: Platform Info + Join Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF4FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.videocam_outlined,
                      color: AppLightColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    'يفتح عبر ${lesson.platform}',
                    style: font12w500.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              BounceIt(
                onPressed: () async {
                  if (lesson.joinUrl.isNotEmpty) {
                    EasyLoading.show(status: 'جاري التحضير...');
                    try {
                      await UrlLauncherUtil.launchAnyUrl(lesson.joinUrl);
                      EasyLoading.dismiss();
                    } catch (_) {
                      EasyLoading.dismiss();
                      showError('تعذر فتح الرابط');
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'انضم للحصة',
                        style: font14w700.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
