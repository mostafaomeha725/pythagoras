import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_info_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_text_field.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_state.dart';

class ContactUsScreenBody extends StatefulWidget {
  const ContactUsScreenBody({super.key});

  @override
  State<ContactUsScreenBody> createState() => _ContactUsScreenBodyState();
}

class _ContactUsScreenBodyState extends State<ContactUsScreenBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_nameController.text.trim().isEmpty || 
          _emailController.text.trim().isEmpty || 
          _messageController.text.trim().isEmpty) {
        EasyLoading.showError('يرجى ملء جميع الحقول');
        return;
      }
      
      context.read<ContactUsCubit>().submit(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactUsCubit, ContactUsState>(
      listener: (context, state) {
        if (state is ContactUsLoading) {
          EasyLoading.show(status: 'جاري الإرسال...');
        } else if (state is ContactUsSuccess) {
          EasyLoading.showSuccess(state.message);
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
        } else if (state is ContactUsError) {
          EasyLoading.showError(state.message);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: AppText(
                  'هل لديك سؤال، أو تحتاج إلى مساعدة، أو تريد فقط أن تقول مرحباً؟ فريق الدعم لدينا هنا لمساعدتك.',
                  style: font14w500.copyWith(color: const Color(0xFF6B7280)),
                  alignment: AlignmentDirectional.center,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 16.h),

              // Phone Card
              const ContactInfoCard(
                text: '65608054',
                icon: Icons.phone_in_talk_outlined,
              ),
              SizedBox(height: 12.h),

              // Email Card
              const ContactInfoCard(
                text: 'info@neudrosi-pythagoras.com',
                icon: Icons.email_outlined,
              ),
              SizedBox(height: 24.h),

              // Name Field
              ContactTextField(
                label: 'الاسم',
                hint: 'اكتب اسمك',
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              SizedBox(height: 16.h),

              // Email Field
              ContactTextField(
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              SizedBox(height: 16.h),

              // Message Field
              ContactTextField(
                label: 'الرسالة',
                hint: 'اكتب رسالتك',
                icon: Icons.edit_outlined,
                maxLines: 4,
                controller: _messageController,
              ),
              SizedBox(height: 32.h),

              // Submit Button
              BounceIt(
                onPressed: _submitForm,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    'إرسال',
                    style: font16w700.copyWith(color: Colors.white),
                    alignment: AlignmentDirectional.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
