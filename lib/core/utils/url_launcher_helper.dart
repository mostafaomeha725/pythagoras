import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<bool> openUrl(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return false;
    final uri = Uri.parse(cleanUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {}

    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
