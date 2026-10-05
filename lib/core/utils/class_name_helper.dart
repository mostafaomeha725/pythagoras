class ClassNameHelper {
  static String? getClassName(int classId) {
    switch (classId) {
      case 1:
        return 'الصف العاشر';
      case 2:
        return 'الصف الحادي عشر - علمي';
      case 3:
        return 'الصف الحادي عشر - أدبي';
      case 4:
        return 'الصف الثاني عشر - علمي';
      case 5:
        return 'الصف الثاني عشر - أدبي';
      case 6:
        return 'الصف السادس';
      case 7:
        return 'الصف السابع';
      case 8:
        return 'الصف الثامن';
      case 9:
        return 'الصف التاسع';
      default:
        return null;
    }
  }
}
