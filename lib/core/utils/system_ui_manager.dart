import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SystemUiManager {
  static Future<void> enterFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Restores system UI overlays and sets orientation upon exiting fullscreen.
  ///
  /// - On [mobile]: forces [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
  ///   strictly maintaining existing mobile behavior.
  /// - On [tablet]:
  ///   - If [targetOrientation] is [Orientation.landscape]: preserves landscape
  ///     without forcing portrait.
  ///   - If [targetOrientation] is [Orientation.portrait]: returns to portrait.
  ///   - If [unlockAfter] is true: clears orientation locks (`[]`) so the tablet
  ///     can respond to physical sensor rotation.
  static Future<void> exitFullscreen({
    bool isTablet = false,
    Orientation? targetOrientation,
    bool unlockAfter = false,
  }) async {
    if (isTablet) {
      if (targetOrientation == Orientation.landscape) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      if (unlockAfter) {
        await unlockOrientations();
      }
    } else {
      // Mobile behavior: strictly preserved
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  /// Unlocks orientations (empty list) so that devices that support auto-rotation
  /// (such as tablets) can rotate according to the physical sensor.
  static Future<void> unlockOrientations() async {
    await SystemChrome.setPreferredOrientations([]);
  }
}
