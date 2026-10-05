import 'package:flutter/material.dart';

import '../widgets/choose_user_type_body.dart';

class ChooseUserTypeScreen extends StatelessWidget {
  const ChooseUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChooseUserTypeBody(),
    );
  }
}
