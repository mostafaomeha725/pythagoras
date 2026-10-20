import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';

/// Question options list optimized for Tablet Landscape.
/// Uses clear radio indicators, responsive borders, and non-ScreenUtil sizing.
class QuizTabletOptionsList extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedOptionId;
  final Function(int) onOptionSelected;

  const QuizTabletOptionsList({
    super.key,
    required this.question,
    this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages =
        question.options.any((o) => o.imageUrl != null && o.imageUrl!.isNotEmpty);

    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOptionId == option.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onOptionSelected(option.id),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF832561)
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF832561).withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasImages &&
                      option.imageUrl != null &&
                      option.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(13)),
                      child: AppImage(
                        imageUrl: option.imageUrl!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Radio Circle (Right in RTL)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF832561)
                                  : const Color(0xFFD1D5DB),
                              width: isSelected ? 6 : 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Option Text
                        Expanded(
                          child: AppText(
                            option.text ?? '',
                            style: font14w700.copyWith(
                              color: const Color(0xFF1E1E2D),
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
