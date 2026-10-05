import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/webview_screen_body.dart';

class WebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CourseDetailAppBar(title: title),
      body: WebViewScreenBody(url: url),
    );
  }
}
