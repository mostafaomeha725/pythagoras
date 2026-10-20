import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';

class CourseReviewItemCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String reviewText;
  final int helpfulCount;
  final String imageUrl;

  const CourseReviewItemCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.reviewText,
    required this.helpfulCount,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: AppImage(
                  imageUrl: imageUrl,
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: font14w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: font10w700.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              child: Icon(
                                index < rating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFFBBF24),
                                size: 12.sp,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: font10w400.copyWith(color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
          // Review Text
          if (reviewText.trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              reviewText,
              style: font12w400.copyWith(
                color: const Color(0xFF4B5563),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
