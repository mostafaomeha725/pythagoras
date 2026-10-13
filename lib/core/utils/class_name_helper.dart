import 'package:pythagoras/features/courses/domain/entities/student_class.dart';

class ClassNameHelper {
  /// Resolves the class name dynamically from [classes] (from API/cache).
  /// Falls back to the static map if [classes] is empty or id not found.
  static String? getClassName(int classId, {List<StudentClass>? classes}) {
    // 1. Dynamic lookup from loaded classes list (preferred)
    if (classes != null && classes.isNotEmpty) {
      try {
        final match = classes.firstWhere((c) => c.id == classId);
        return match.name;
      } catch (_) {
        // id not found in list – fall through to static fallback
      }
    }

    // 2. Static fallback map (used only when classes list unavailable)
    const staticMap = <int, String>{
      1: 'الصف العاشر',
      2: 'الصف الحادي عشر - علمي',
      3: 'الصف الحادي عشر - أدبي',
      4: 'الصف الثاني عشر - علمي',
      5: 'الصف الثاني عشر - أدبي',
      6: 'الصف السادس',
      7: 'الصف السابع',
      8: 'الصف الثامن',
      9: 'الصف التاسع',
    };
    return staticMap[classId];
  }
}
