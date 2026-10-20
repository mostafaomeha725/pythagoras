import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_cubit.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_screen_body.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            ResponsiveHelper.isTablet(context) ||
            (constraints.maxWidth >= 900 &&
                constraints.maxWidth > constraints.maxHeight);

        return Scaffold(
          appBar: isTablet
              ? null
              : const CourseDetailAppBar(title: 'تواصل معنا'),
          body: SafeArea(
            child: BlocProvider(
              create: (context) => sl<ContactUsCubit>(),
              child: const ContactUsScreenBody(),
            ),
          ),
        );
      },
    );
  }
}
