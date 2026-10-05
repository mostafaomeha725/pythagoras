import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseWebviewPlayer extends StatelessWidget {
  final WebViewController controller;

  const CourseWebviewPlayer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      width: double.infinity,
      child: WebViewWidget(controller: controller),
    );
  }
}
