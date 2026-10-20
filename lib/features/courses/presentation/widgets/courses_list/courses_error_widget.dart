import 'package:flutter/material.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';

class CoursesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CoursesErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return NoInternetWidget(message: message, onRetry: onRetry);
  }
}
