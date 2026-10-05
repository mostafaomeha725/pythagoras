class DateFormatter {
  static String format(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String formatYMD(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final datePart = dateStr.split('T').first;
      final parts = datePart.split('-');
      return '${int.parse(parts[2])}/${int.parse(parts[1])}/${parts[0]}';
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTimeString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // Extract time from ISO 8601 string ignoring local timezone conversions
      // Example: "2026-09-30T16:35:00+03:00" -> "16:35"
      final timePart = dateStr.split('T').last;
      final timeWithoutOffset = timePart.split('+').first.split('-').first;
      final parts = timeWithoutOffset.split(':');

      final hourInt = int.parse(parts[0]);
      final minuteInt = int.parse(parts[1]);

      final hour12 = hourInt % 12 == 0 ? 12 : hourInt % 12;

      return '$hour12:${minuteInt.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
