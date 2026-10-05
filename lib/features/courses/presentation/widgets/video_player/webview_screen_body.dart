import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

class WebViewScreenBody extends StatefulWidget {
  final String url;

  const WebViewScreenBody({super.key, required this.url});

  @override
  State<WebViewScreenBody> createState() => _WebViewScreenBodyState();
}

class _WebViewScreenBodyState extends State<WebViewScreenBody> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // For non-PDF documents (docx, pptx, xlsx), we use Google Docs viewer
    final encodedUrl = Uri.encodeComponent(widget.url);
    final viewerUrl = 'https://docs.google.com/gview?embedded=true&url=$encodedUrl';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            EasyLoading.showError('حدث خطأ أثناء تحميل الملف');
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Center(
            child: SpinKitFadingCircle(
              color: AppLightColors.primary,
              size: 40.0,
            ),
          ),
      ],
    );
  }
}
