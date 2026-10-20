import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/web_view_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/webview_screen_body.dart';

class WebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLandscape =
            constraints.maxWidth >= 900 &&
            constraints.maxHeight >= 600 &&
            constraints.maxWidth > constraints.maxHeight;

        if (isTabletLandscape) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
              child: WebViewTabletLandscape(title: title, url: url),
            ),
          );
        }

        // Original layout for Mobile Portrait & Tablet Portrait completely untouched
        return Scaffold(
          appBar: CourseDetailAppBar(title: title),
          body: WebViewScreenBody(url: url),
        );
      },
    );
  }
}
