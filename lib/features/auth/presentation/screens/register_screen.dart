import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_cubit.dart';
import '../widgets/register_screen_body.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<WhatsappRegisterCubit>(),
        child: const RegisterScreenBody(),
      ),
    );
  }
}
