import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';

import '../widgets/login_screen_body.dart';

class LoginScreen extends StatelessWidget {
  final bool returnBack;
  const LoginScreen({super.key, this.returnBack = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: Scaffold(
        body: LoginScreenBody(returnBack: returnBack),
      ),
    );
  }
}
