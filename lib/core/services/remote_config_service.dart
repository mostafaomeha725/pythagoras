import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static const String iosIapEnabledKey = 'ios_iap_enabled';
  static const String courseLessonRequestsEnabledKey =
      'enable_course_lesson_requests';
  static const String deleteAccountEnabledKey = 'enable_delete_account';

  final FirebaseRemoteConfig? _remoteConfig;
  bool _iosIapEnabled = false;
  bool _courseLessonRequestsEnabled = true;
  bool _deleteAccountEnabled = true;
  Future<void>? _initialization;
  final bool _isIos;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig, bool? isIos})
    : _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS,
      _remoteConfig =
          remoteConfig ??
          (Firebase.apps.isNotEmpty ? FirebaseRemoteConfig.instance : null);

  bool get iosIapEnabled => _iosIapEnabled;
  bool get courseLessonRequestsEnabled =>
      _isIos ? _courseLessonRequestsEnabled : true;
  bool get deleteAccountEnabled => _deleteAccountEnabled;

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

  Stream<bool> get deleteAccountEnabledChanges {
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return const Stream<bool>.empty();

    return remoteConfig.onConfigUpdated.asyncMap((_) async {
      try {
        await remoteConfig.activate();
        _deleteAccountEnabled = remoteConfig.getBool(deleteAccountEnabledKey);
      } catch (_) {
        // Keep the last activated value when a config refresh fails.
      }
      return _deleteAccountEnabled;
    });
  }

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    _iosIapEnabled = false;
    _courseLessonRequestsEnabled = true;
    _deleteAccountEnabled = true;

    try {
      final remoteConfig = _remoteConfig;
      if (remoteConfig == null) return;

      await remoteConfig.setDefaults({
        iosIapEnabledKey: false,
        courseLessonRequestsEnabledKey: true,
        deleteAccountEnabledKey: true,
      });
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      final activated = await remoteConfig.fetchAndActivate();
      debugPrint('[RemoteConfig] fetchAndActivate=$activated');
      _iosIapEnabled = remoteConfig.getBool(iosIapEnabledKey);
      _courseLessonRequestsEnabled = remoteConfig.getBool(
        courseLessonRequestsEnabledKey,
      );
      _deleteAccountEnabled = remoteConfig.getBool(deleteAccountEnabledKey);
      debugPrint('[IAP][RemoteConfig] $iosIapEnabledKey=$_iosIapEnabled');
      debugPrint(
        '[RemoteConfig] $deleteAccountEnabledKey=$_deleteAccountEnabled',
      );
      debugPrint(
        '[RemoteConfig] valueSource=${remoteConfig.getValue(deleteAccountEnabledKey).source}',
      );
    } catch (_) {
      _iosIapEnabled = false;
      _courseLessonRequestsEnabled = true;
      _deleteAccountEnabled = true;
      debugPrint('[IAP][RemoteConfig] initialization failed; enabled=false');
    }
  }
}
