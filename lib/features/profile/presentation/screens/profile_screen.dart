import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_screen_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          'حسابي',
          style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
          alignment: AlignmentDirectional.center,
        ),
      ),
      body: const SafeArea(child: ProfileScreenBody()),
    );
  }
}
