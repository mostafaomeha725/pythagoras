import 'dart:convert';

class ApplePurchaseResponseSanitizer {
  static String sanitizeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return const JsonEncoder.withIndent('  ').convert(_sanitizeValue(decoded));
    } on FormatException {
      return sanitizeText(body);
    }
  }

  static String sanitizeText(String value) {
    var sanitized = value.replaceAllMapped(
      RegExp(
        r'''((?:authorization|access[_-]?token|refresh[_-]?token|token|secret|password|signedTransaction|receipt|email|phone|userId|account)*\s*[:=]\s*)(?:"[^"]*"|'[^']*'|[^\s,;]+)''',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}[REDACTED]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'\bBearer\s+[^\s,;]+', caseSensitive: false),
      'Bearer [REDACTED]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(
        r'\b[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b',
      ),
      '[REDACTED]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(
        r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
        caseSensitive: false,
      ),
      '[REDACTED]',
    );
    return sanitized;
  }

  static Object? _sanitizeValue(Object? value, [String? key]) {
    if (key != null && _isSensitiveKey(key)) return '[REDACTED]';
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(
          key.toString(),
          _sanitizeValue(value, key.toString()),
        ),
      );
    }
    if (value is List) {
      return value.map(_sanitizeValue).toList(growable: false);
    }
    if (value is String) return sanitizeText(value);
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    return normalized.contains('authorization') ||
        normalized.contains('token') ||
        normalized.contains('secret') ||
        normalized.contains('password') ||
        normalized.contains('signedtransaction') ||
        normalized.contains('receipt') ||
        normalized.contains('email') ||
        normalized.contains('phone') ||
        normalized.contains('userid') ||
        normalized.contains('account') ||
        normalized.contains('customer') ||
        normalized.contains('fullname') ||
        normalized == 'user';
  }
}