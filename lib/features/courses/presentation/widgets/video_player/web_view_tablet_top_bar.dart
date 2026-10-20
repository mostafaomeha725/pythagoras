import 'package:flutter/material.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/web_view_tablet_document_badge.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/web_view_tablet_download_button.dart';

/// Top bar for Web/Document Viewer on Tablet Landscape.
/// Reuses [CourseDetailTabletTopBar] with document badge, reload, and download actions.
class WebViewTabletTopBar extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onReload;

  const WebViewTabletTopBar({
    super.key,
    required this.title,
    required this.url,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return CourseDetailTabletTopBar(
      title: title,
      titleFontSize: 18,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      leading: WebViewTabletDocumentBadge(url: url, title: title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BounceIt(
            onPressed: onReload,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF4B5563),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          WebViewTabletDownloadButton(url: url, title: title),
        ],
      ),
    );
  }
}
