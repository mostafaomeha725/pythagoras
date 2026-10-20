import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/pdf_viewer/pdf_viewer_tablet_top_bar.dart';

/// PDF Viewer layout optimized for Tablet Landscape.
/// Provides a dedicated top bar and an elevated document container.
class PdfViewerTabletLandscape extends StatelessWidget {
  final String title;
  final String url;

  const PdfViewerTabletLandscape({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar with back button, PDF badge, title and download button
        PdfViewerTabletTopBar(title: title, url: url),

        // Document Container
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child:
                const PDF(
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: false,
                  fitEachPage: true,
                ).cachedFromUrl(
                  url,
                  placeholder: (progress) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SpinKitFadingCircle(
                          color: AppLightColors.primary,
                          size: 42.0,
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          'جاري تحميل المستند $progress%...',
                          style: font14w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ],
                    ),
                  ),
                  errorWidget: (error) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 44,
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          'تعذر فتح ملف الـ PDF',
                          style: font16w700.copyWith(
                            color: const Color(0xFF1E1E2D),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                          style: font12w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
