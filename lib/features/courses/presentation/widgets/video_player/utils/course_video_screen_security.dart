import 'package:flutter/foundation.dart';
import 'package:screen_protector/screen_protector.dart';

class CourseVideoScreenSecurity {
  CourseVideoScreenSecurity._();

  static Future<void> enable() async {
    try {
      await ScreenProtector.protectDataLeakageOn();
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('ScreenProtector enable failed: $e');
    }
  }

  static Future<void> disable() async {
    try {
      await ScreenProtector.protectDataLeakageOff();
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint('ScreenProtector disable failed: $e');
    }
  }
}
