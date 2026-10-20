import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_screen_body.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';

class EditProfileScreen extends StatelessWidget {
  final UserProfile? userProfile;
  const EditProfileScreen({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EditProfileCubit>(),
      child: EditProfileScreenBody(userProfile: userProfile),
    );
  }
}
