import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtil {
  /// Opens a WhatsApp URL reliably across all Android and iOS devices.
  /// Formats course, chapter, and registration messages into a clean Arabic layout,
  /// resolves any URL double-encoding (%D9%85 -> Arabic), and provides multi-mode fallbacks.
  /// Opens a WhatsApp URL reliably across all Android and iOS devices.
  /// Formats course, chapter, and registration messages into a clean Arabic layout,
  /// resolves any URL double-encoding (%D9%85 -> Arabic), and provides multi-mode fallbacks.
  static Future<bool> openWhatsAppUrl(
    String urlString, {
    String? chapterTitle,
    String? courseTitle,
    bool? isChapter,
  }) async {
    final cleanUrl = urlString.trim();
    if (cleanUrl.isEmpty) return false;

    final uris = _parseAndFormatWhatsApp(
      cleanUrl,
      chapterTitle: chapterTitle,
      courseTitle: courseTitle,
      isChapter: isChapter,
    );

    // 1. Try launching with native whatsapp:// scheme in externalApplication mode
    try {
      final launched = await launchUrl(
        uris.appUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (e) {
      debugPrint('LaunchMode.externalApplication native failed: $e');
    }

    // 2. Try launching with native whatsapp:// scheme in platformDefault mode
    try {
      final launched = await launchUrl(uris.appUri);
      if (launched) return true;
    } catch (e) {
      debugPrint('Default launchUrl native failed: $e');
    }

    // 3. Web fallback: https://api.whatsapp.com/send in externalApplication mode
    try {
      final launched = await launchUrl(
        uris.webUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (e) {
      debugPrint('Web fallback external failed: $e');
    }

    // 4. Final attempt: web fallback in platformDefault mode
    try {
      final launched = await launchUrl(uris.webUri);
      if (launched) return true;
    } catch (e) {
      debugPrint('Web fallback default failed: $e');
    }

    return false;
  }

  /// Parses phone and text from incoming URL, eliminates any percent double-encoding,
  /// formats message, and constructs pristine app and web URIs.
  static _WhatsAppUris _parseAndFormatWhatsApp(
    String urlString, {
    String? chapterTitle,
    String? courseTitle,
    bool? isChapter,
  }) {
    String phone = '';
    String rawText = '';

    try {
      final uri = Uri.parse(urlString);
      phone = uri.queryParameters['phone'] ?? '';
      rawText = uri.queryParameters['text'] ?? '';
      if (phone.isEmpty && uri.host == 'wa.me') {
        phone = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      }
    } catch (_) {
      final phoneMatch = RegExp(r'[?&]phone=([^&]+)').firstMatch(urlString);
      if (phoneMatch != null) phone = phoneMatch.group(1) ?? '';
      final textMatch = RegExp(r'[?&]text=([^&]+)').firstMatch(urlString);
      if (textMatch != null) rawText = textMatch.group(1) ?? '';
    }

    // Decode repeatedly until fully clean Arabic (eliminating %D9 / %20 / double-encoding)
    while (rawText.contains('%') &&
        RegExp(r'%[0-9A-Fa-f]{2}').hasMatch(rawText)) {
      try {
        final decoded = Uri.decodeComponent(rawText);
        if (decoded == rawText) break;
        rawText = decoded;
      } catch (_) {
        break;
      }
    }

    final formattedText = _formatWhatsAppMessage(
      rawText,
      chapterTitle: chapterTitle,
      courseTitle: courseTitle,
      isChapter: isChapter,
    );

    final appUri = Uri(
      scheme: 'whatsapp',
      host: 'send',
      queryParameters: {
        if (phone.isNotEmpty) 'phone': phone,
        'text': formattedText,
      },
    );

    final webUri = Uri.https(
      'api.whatsapp.com',
      '/send',
      {
        if (phone.isNotEmpty) 'phone': phone,
        'text': formattedText,
      },
    );

    return _WhatsAppUris(appUri: appUri, webUri: webUri);
  }

  /// Formats raw text into a professional WhatsApp markdown template
  /// for course requests, chapter requests, and user registration.
  static String _formatWhatsAppMessage(
    String text, {
    String? chapterTitle,
    String? courseTitle,
    bool? isChapter,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return '✨ *طلب إنشاء حساب جديد - منصة فيثاغورس* 📐\n\n'
          'السلام عليكم ورحمة الله وبركاته 🌹\n'
          'أرغب في إنشاء حساب جديد والانضمام لمنصة فيثاغورس التعليمية.\n\n'
          'يرجى تزويدي بخطوات إكمال التسجيل والتفعيل، شكراً جزيلاً! 🌸';
    }

    // Return as-is if already formatted
    if (trimmed.contains('منصة فيثاغورس') &&
        trimmed.contains('━━━━━━━━━━━━━━━━━━━━')) {
      return text;
    }

    final lines = trimmed
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final Map<String, String> data = {};

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final key = parts[0].trim();
        final val = parts.sublist(1).join(':').trim();
        data[key] = val;
      }
    }

    final bool treatAsChapter = (isChapter == true) ||
        (chapterTitle != null && chapterTitle.trim().isNotEmpty) ||
        ((data.containsKey('الحصة') ||
                data.containsKey('الفصل') ||
                data.containsKey('الدرس')) &&
            !data.containsKey('الكورس'));

    final courseName = courseTitle ?? data['الكورس'] ?? data['الدورة'];
    final chapterName = chapterTitle ??
        data['الحصة'] ??
        data['الفصل'] ??
        data['الدرس'];
    final price = data['السعر'];
    final orderId = data['رقم الطلب'];
    final name = data['الاسم'];
    final phone = data['الهاتف'];

    final hasCourse = data.containsKey('الكورس') || data.containsKey('الدورة');
    final hasOrderId = data.containsKey('رقم الطلب');

    // Case 1 & 2: Course or Chapter Subscription Request
    if (treatAsChapter || hasCourse || hasOrderId) {
      final buffer = StringBuffer();

      if (treatAsChapter) {
        buffer.writeln('✨ *طلب اشتراك في حصة دراسية - منصة فيثاغورس* 📐');
        buffer.writeln();
        buffer.writeln('السلام عليكم ورحمة الله وبركاته 🌹');
        buffer.writeln('أرغب في تأكيد الاشتراك في الحصة بالبيانات التالية:');
        buffer.writeln();
        buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
        buffer.writeln('📖 *تفاصيل الحصة:*');
        if (chapterName != null && chapterName.isNotEmpty) {
          buffer.writeln('▫️ *اسم الحصة:* $chapterName');
        }
        if (courseName != null && courseName.isNotEmpty) {
          buffer.writeln('▫️ *الدورة التابعة لها:* $courseName');
        }
        if (price != null && price.isNotEmpty) {
          buffer.writeln('▫️ *قيمة الاشتراك:* $price');
        }
        if (orderId != null && orderId.isNotEmpty) {
          buffer.writeln('▫️ *رقم الطلب:* #$orderId');
        }
        buffer.writeln();
        buffer.writeln('👤 *بيانات الطالب:*');
        if (name != null && name.isNotEmpty) {
          buffer.writeln('▫️ *الاسم:* $name');
        }
        if (phone != null && phone.isNotEmpty) {
          buffer.writeln('▫️ *الهاتف:* $phone');
        }
        buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
        buffer.writeln();
        buffer.write('يرجى تأكيد وتفعيل الحصة، شاكر ومقدر لتعاونكم! 🌸');
        return buffer.toString();
      } else {
        buffer.writeln('✨ *طلب اشتراك في دورة جديدة - منصة فيثاغورس* 📐');
        buffer.writeln();
        buffer.writeln('السلام عليكم ورحمة الله وبركاته 🌹');
        buffer.writeln('أرغب في تأكيد الاشتراك بالبيانات التالية:');
        buffer.writeln();
        buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
        buffer.writeln('📚 *تفاصيل الدورة:*');
        if (courseName != null && courseName.isNotEmpty) {
          buffer.writeln('▫️ *اسم الدورة:* $courseName');
        }
        if (price != null && price.isNotEmpty) {
          buffer.writeln('▫️ *قيمة الاشتراك:* $price');
        }
        if (orderId != null && orderId.isNotEmpty) {
          buffer.writeln('▫️ *رقم الطلب:* #$orderId');
        }
        buffer.writeln();
        buffer.writeln('👤 *بيانات الطالب:*');
        if (name != null && name.isNotEmpty) {
          buffer.writeln('▫️ *الاسم:* $name');
        }
        if (phone != null && phone.isNotEmpty) {
          buffer.writeln('▫️ *الهاتف:* $phone');
        }
        buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
        buffer.writeln();
        buffer.write('يرجى تأكيد وتفعيل الاشتراك، شاكر ومقدر لتعاونكم! 🌸');
        return buffer.toString();
      }
    }

    // Case 3: Register / Account Creation Request
    final lower = trimmed.toLowerCase();
    final isRegister = trimmed.contains('حساب') ||
        trimmed.contains('تسجيل') ||
        trimmed.contains('إنشاء') ||
        lower.contains('register');

    if (isRegister) {
      final buffer = StringBuffer();
      buffer.writeln('✨ *طلب إنشاء حساب جديد - منصة فيثاغورس* 📐');
      buffer.writeln();
      buffer.writeln('السلام عليكم ورحمة الله وبركاته 🌹');
      buffer.writeln(
          'أرغب في إنشاء حساب جديد والانضمام لمنصة فيثاغورس التعليمية.');
      buffer.writeln();
      buffer.write('يرجى تزويدي بخطوات إكمال التسجيل والتفعيل، شكراً جزيلاً! 🌸');
      return buffer.toString();
    }

    return text;
  }

  static Future<void> launchAnyUrl(String urlString) async {
    final cleanUrl = urlString.trim();
    if (cleanUrl.isEmpty) throw 'URL is empty';

    final Uri url = Uri.parse(Uri.encodeFull(cleanUrl));
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}

    try {
      final launched = await launchUrl(url);
      if (launched) return;
    } catch (_) {}

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  static Future<void> launchPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  static Future<void> launchEmail(String postEmail) async {
    Uri email = Uri(
      scheme: 'mailto',
      path: postEmail,
      query: Uri.encodeQueryComponent('subject=Testing subject'),
    );
    bool canLaunch = await canLaunchUrl(email);
    debugPrint('Can launch email: $canLaunch'); // Debug line

    if (canLaunch) {
      await launchUrl(email, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $email');
    }
  }

  static Future<void> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    bool canLaunchWhatsApp = await canLaunchUrl(whatsappUri);
    debugPrint('Can launch WhatsApp: $canLaunchWhatsApp'); // Debug line

    if (canLaunchWhatsApp) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }

  static Future<bool> launchMap({
    required double latitude,
    required double longitude,
  }) async {
    final destination = '$latitude,$longitude';
    final appUri = Uri.parse('google.navigation:q=$destination&mode=d');
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving',
    );

    var launched = await launchUrl(
      appUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    return launched;
  }
}

class _WhatsAppUris {
  final Uri appUri;
  final Uri webUri;

  const _WhatsAppUris({required this.appUri, required this.webUri});
}
