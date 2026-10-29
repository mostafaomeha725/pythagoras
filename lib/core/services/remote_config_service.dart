import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static const String iosIapEnabledKey = 'ios_iap_enabled';
  static const String courseLessonRequestsEnabledKey =
      'enable_course_lesson_requests';

  final FirebaseRemoteConfig? _remoteConfig;
  bool _iosIapEnabled = false;
  bool _courseLessonRequestsEnabled = true;
  Future<void>? _initialization;
  final bool _isIos;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig, bool? isIos})
    : _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS,
      _remoteConfig = (isIos ?? defaultTargetPlatform == TargetPlatform.iOS)
          ? (remoteConfig ?? FirebaseRemoteConfig.instance)
          : null;

  bool get iosIapEnabled => _iosIapEnabled;
  bool get courseLessonRequestsEnabled =>
      _isIos ? _courseLessonRequestsEnabled : true;

  Stream<bool> get iosIapEnabledChanges {
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return const Stream<bool>.empty();

    return remoteConfig.onConfigUpdated.asyncMap((_) async {
      try {
        await remoteConfig.activate();
        _iosIapEnabled = remoteConfig.getBool(iosIapEnabledKey);
      } catch (_) {
        _iosIapEnabled = false;
      }
      return _iosIapEnabled;
    });
  }

  Stream<bool> get courseLessonRequestsEnabledChanges {
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return const Stream<bool>.empty();

    return remoteConfig.onConfigUpdated.asyncMap((_) async {
      try {
        await remoteConfig.activate();
        _courseLessonRequestsEnabled = remoteConfig.getBool(
          courseLessonRequestsEnabledKey,
        );
      } catch (_) {
        // Keep the last activated value when a config refresh fails.
      }
      return courseLessonRequestsEnabled;
    });
  }

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (!_isIos) return;

    _iosIapEnabled = false;
    _courseLessonRequestsEnabled = true;

    try {
      final remoteConfig = _remoteConfig;
      if (remoteConfig == null) return;

      await remoteConfig.setDefaults({
        iosIapEnabledKey: false,
        courseLessonRequestsEnabledKey: true,
      });
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      _iosIapEnabled = remoteConfig.getBool(iosIapEnabledKey);
      _courseLessonRequestsEnabled = remoteConfig.getBool(
        courseLessonRequestsEnabledKey,
      );
      debugPrint('[IAP][RemoteConfig] $iosIapEnabledKey=$_iosIapEnabled');
    } catch (_) {
      _iosIapEnabled = false;
      _courseLessonRequestsEnabled = true;
      debugPrint('[IAP][RemoteConfig] initialization failed; enabled=false');
    }
  }
}
