import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_text_field.dart';

/// Form Card for Contact Us on Tablet.
class ContactUsTabletFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final VoidCallback onSubmit;

  const ContactUsTabletFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.messageController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Title & Subtitle
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEEFA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mail_outline_rounded,
                      color: AppLightColors.primary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'إرسال رسالة مباشرة',
                        style: font16w700.copyWith(
                          color: const Color(0xFF1E1E2D),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        'املأ البيانات أدناه وسيتواصل معك فريق الدعم قريباً',
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Two-column row for Name and Email if wide enough, otherwise stacked
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 460;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ContactUsTabletTextField(
                          label: 'الاسم',
                          hint: 'اكتب اسمك',
                          icon: Icons.person_outline,
                          controller: nameController,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ContactUsTabletTextField(
                          label: 'البريد الإلكتروني',
                          hint: 'example@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ContactUsTabletTextField(
                      label: 'الاسم',
                      hint: 'اكتب اسمك',
                      icon: Icons.person_outline,
                      controller: nameController,
                    ),
                    const SizedBox(height: 12),
                    ContactUsTabletTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'example@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Message Field
            ContactUsTabletTextField(
              label: 'الرسالة',
              hint: 'اكتب رسالتك أو استفسارك هنا بالتفصيل...',
              icon: Icons.edit_outlined,
              maxLines: 4,
              controller: messageController,
            ),
            const SizedBox(height: 18),

            // Submit Button
            BounceIt(
              onPressed: onSubmit,
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: AppLightColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppLightColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      'إرسال الرسالة',
                      style: font16w700.copyWith(
                        color: Colors.white,
                        fontSize: 14.5,
                      ),
                      alignment: AlignmentDirectional.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
