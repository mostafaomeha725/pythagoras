import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static const String iosIapEnabledKey = 'ios_iap_enabled';

  final FirebaseRemoteConfig? _remoteConfig;
  bool _iosIapEnabled = false;
  Future<void>? _initialization;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = defaultTargetPlatform == TargetPlatform.iOS
          ? (remoteConfig ?? FirebaseRemoteConfig.instance)
          : null;

  bool get iosIapEnabled => _iosIapEnabled;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    _iosIapEnabled = false;

    try {
      final remoteConfig = _remoteConfig;
      if (remoteConfig == null) return;

      await remoteConfig.setDefaults({iosIapEnabledKey: false});
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      _iosIapEnabled = remoteConfig.getBool(iosIapEnabledKey);
    } catch (_) {
      _iosIapEnabled = false;
    }
  }
}
