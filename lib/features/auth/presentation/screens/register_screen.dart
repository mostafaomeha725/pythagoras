import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_cubit.dart';
import '../widgets/ios_register/ios_register_screen_body.dart';
import '../widgets/register_screen_body.dart';

class RegisterScreen extends StatelessWidget {
  final bool? isIosOverride;
  const RegisterScreen({super.key, this.isIosOverride});

  @override
  Widget build(BuildContext context) {
    final isIOS =
        isIosOverride ?? (Theme.of(context).platform == TargetPlatform.iOS);

    if (isIOS) {
      return BlocProvider(
        create: (context) => sl<IosRegisterCubit>()..loadClasses(),
        child: const Scaffold(body: IosRegisterScreenBody()),
      );
    }

    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<WhatsappRegisterCubit>(),
        child: const RegisterScreenBody(),
      ),
    );
  }
}
