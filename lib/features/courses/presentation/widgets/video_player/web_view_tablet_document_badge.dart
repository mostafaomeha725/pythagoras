import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Document type badge for WebView Tablet Top Bar.
/// Auto-detects extension (PPT, XLS, DOC) and renders a styled badge.
class WebViewTabletDocumentBadge extends StatelessWidget {
  final String url;
  final String title;

  const WebViewTabletDocumentBadge({
    super.key,
    required this.url,
    required this.title,
  });

  Map<String, dynamic> _getDocumentBadgeInfo() {
    final cleanUrl = url.toLowerCase().split('?').first;
    final cleanTitle = title.toLowerCase();

    if (cleanUrl.endsWith('.ppt') ||
        cleanUrl.endsWith('.pptx') ||
        cleanTitle.contains('ppt')) {
      return {
        'label': 'PPT',
        'icon': Icons.slideshow_outlined,
        'bg': const Color(0xFFFFF7ED),
        'fg': const Color(0xFFEA580C),
      };
    } else if (cleanUrl.endsWith('.xls') ||
        cleanUrl.endsWith('.xlsx') ||
        cleanTitle.contains('xls')) {
      return {
        'label': 'XLS',
        'icon': Icons.table_chart_outlined,
        'bg': const Color(0xFFECFDF5),
        'fg': const Color(0xFF059669),
      };
    } else {
      return {
        'label': 'DOC',
        'icon': Icons.description_outlined,
        'bg': const Color(0xFFEFF6FF),
        'fg': const Color(0xFF2563EB),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getDocumentBadgeInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badge['bg'] as Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badge['icon'] as IconData,
            color: badge['fg'] as Color,
            size: 16,
          ),
          const SizedBox(width: 4),
          AppText(
            badge['label'] as String,
            style: font12w700.copyWith(
              color: badge['fg'] as Color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
