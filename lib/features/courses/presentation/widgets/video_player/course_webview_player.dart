import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseWebviewPlayer extends StatefulWidget {
  final WebViewController controller;

  const CourseWebviewPlayer({super.key, required this.controller});

  @override
  State<CourseWebviewPlayer> createState() => _CourseWebviewPlayerState();
}

class _CourseWebviewPlayerState extends State<CourseWebviewPlayer> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: WebViewWidget(controller: widget.controller),
    );
  }
}
