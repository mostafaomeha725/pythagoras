import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/pdf_viewer/pdf_viewer_tablet_landscape.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String url;

  const PdfViewerScreen({super.key, required this.title, required this.url});

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
              child: PdfViewerTabletLandscape(title: title, url: url),
            ),
          );
        }

        // Original layout for Mobile Portrait & Tablet Portrait completely untouched
        return Scaffold(
          appBar: CourseDetailAppBar(title: title),
          body:
              const PDF(
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: false,
                fitEachPage: true,
              ).cachedFromUrl(
                url,
                placeholder: (progress) => Center(
                  child: SpinKitFadingCircle(
                    color: AppLightColors.primary,
                    size: 40.0,
                  ),
                ),
                errorWidget: (error) => Center(child: Text(error.toString())),
              ),
        );
      },
    );
  }
}
