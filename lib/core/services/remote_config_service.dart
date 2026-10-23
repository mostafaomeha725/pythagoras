import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static const String iosIapEnabledKey = 'ios_iap_enabled';

  final FirebaseRemoteConfig _remoteConfig;
  bool _iosIapEnabled = false;
  Future<void>? _initialization;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  bool get iosIapEnabled => _iosIapEnabled;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    _iosIapEnabled = false;

    try {
      await _remoteConfig.setDefaults({iosIapEnabledKey: false});
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
      _iosIapEnabled = _remoteConfig.getBool(iosIapEnabledKey);
    } catch (_) {
      _iosIapEnabled = false;
    }
  }
}
