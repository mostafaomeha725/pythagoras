import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseWebviewPlayer extends StatefulWidget {
  final WebViewController controller;
  final Widget customControls;

  const CourseWebviewPlayer({
    super.key,
    required this.controller,
    required this.customControls,
  });

  @override
  State<CourseWebviewPlayer> createState() => _CourseWebviewPlayerState();
}

class _CourseWebviewPlayerState extends State<CourseWebviewPlayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        WebViewWidget(controller: widget.controller),
        widget.customControls,
      ],
    );
  }
}
