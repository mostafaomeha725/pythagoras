import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';

class QuizOptionsGrid extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedOptionId;
  final Function(int) onOptionSelected;

  const QuizOptionsGrid({
    super.key,
    required this.question,
    this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = question.options.any((o) => o.imageUrl != null && o.imageUrl!.isNotEmpty);

    if (!hasImages) {
      return Column(
        children: [
          for (int i = 0; i < question.options.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildOptionCard(context, question.options[i], false)),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: i + 1 < question.options.length
                        ? _buildOptionCard(context, question.options[i + 1], false)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return _buildOptionCard(context, question.options[index], true);
      },
    );
  }

  Widget _buildOptionCard(BuildContext context, dynamic option, bool hasImages) {
    final isSelected = selectedOptionId == option.id;
    return InkWell(
      onTap: () => onOptionSelected(option.id),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF832561) : const Color(0xFFF3F4F6),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF832561).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: hasImages ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImages && option.imageUrl != null && option.imageUrl!.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                  child: Image.network(
                    option.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      option.text ?? '',
                      style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF832561) : const Color(0xFFD1D5DB),
                        width: isSelected ? 6.w : 1.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
