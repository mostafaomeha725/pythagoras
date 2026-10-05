import 'package:hive_flutter/hive_flutter.dart';

abstract class CacheService {
  Future<void> saveString(String key, String value);
  String? getString(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class HiveStorage implements CacheService {
  final Box _box;

  HiveStorage(this._box);

  @override
  Future<void> saveString(String key, String value) async {
    await _box.put(key, value);
  }

  @override
  String? getString(String key) {
    return _box.get(key) as String?;
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
