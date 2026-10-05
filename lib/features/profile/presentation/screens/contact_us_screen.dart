import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_screen_body.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_cubit.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CourseDetailAppBar(title: 'تواصل معنا'),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => sl<ContactUsCubit>(),
          child: const ContactUsScreenBody(),
        ),
      ),
    );
  }
}
