import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/web_view_tablet_top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Web and Document Viewer layout optimized for Tablet Landscape.
/// Integrates a dedicated top bar and an elevated document container.
class WebViewTabletLandscape extends StatefulWidget {
  final String title;
  final String url;

  const WebViewTabletLandscape({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewTabletLandscape> createState() => _WebViewTabletLandscapeState();
}

class _WebViewTabletLandscapeState extends State<WebViewTabletLandscape> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final encodedUrl = Uri.encodeComponent(widget.url);
    final viewerUrl =
        'https://docs.google.com/gview?embedded=true&url=$encodedUrl';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) setState(() => _isLoading = false);
            EasyLoading.showError('حدث خطأ أثناء تحميل الملف');
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar with back button, badge, title, reload, and download
        WebViewTabletTopBar(
          title: widget.title,
          url: widget.url,
          onReload: () => _controller.reload(),
        ),

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
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SpinKitFadingCircle(
                          color: AppLightColors.primary,
                          size: 42.0,
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          'جاري فتح المستند...',
                          style: font14w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
