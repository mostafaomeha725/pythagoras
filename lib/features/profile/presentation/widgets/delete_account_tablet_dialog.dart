import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Tablet Landscape confirmation dialog for permanently deleting user account.
/// Designed with balanced proportions, fixed typography, and scrollable warning content
/// to eliminate RenderFlex overflow while keeping action buttons permanently accessible.
class DeleteAccountTabletDialog extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteAccountTabletDialog({
    super.key,
    required this.isLoading,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scrollable Content Area (Icon, Title, Subtitle, Warning Box)
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Red Warning Icon Container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: Color(0xFFDC2626),
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      AppText(
                        'حذف الحساب نهائياً',
                        style: font18w700.copyWith(
                          color: const Color(0xFF1E1E2D),
                          fontSize: 17.5,
                        ),
                        alignment: AlignmentDirectional.center,
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      AppText(
                        'هل أنت متأكد من رغبتك في حذف حسابك؟',
                        style: font14w500.copyWith(
                          color: const Color(0xFF4B5563),
                          fontSize: 13.5,
                        ),
                        alignment: AlignmentDirectional.center,
                      ),
                      const SizedBox(height: 14),

                      // Warning Callout Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                'تنبيه: سيؤدي هذا الإجراء إلى مسح كافة بياناتك وتقدمك الدراسي في الدورات والواجبات بشكل دائم وفوري، ولا يمكن التراجع عن هذا الإجراء.',
                                style: font12w500.copyWith(
                                  color: const Color(0xFF991B1B),
                                  height: 1.52,
                                  fontSize: 12,
                                ),
                                maxLines: 10,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Fixed Action Buttons Row (Always visible and clickable)
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: BounceIt(
                      onPressed: () {
                        if (!isLoading) {
                          onCancel();
                        }
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          'إلغاء',
                          style: font14w600.copyWith(
                            color: const Color(0xFF4B5563),
                            fontSize: 13.5,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Confirm Delete Button
                  Expanded(
                    child: BounceIt(
                      onPressed: () {
                        if (!isLoading) {
                          onConfirm();
                        }
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFDC2626,
                              ).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          'تأكيد الحذف',
                          style: font14w600.copyWith(
                            color: Colors.white,
                            fontSize: 13.5,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
