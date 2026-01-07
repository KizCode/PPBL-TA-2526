import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<void> setBool(String key, bool value) async {
    final p = await _prefs;
    await p.setBool(key, value);
  }

  static Future<void> setString(String key, String value) async {
    final p = await _prefs;
    await p.setString(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final p = await _prefs;
    await p.setInt(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final p = await _prefs;
    return p.getBool(key);
  }

  static Future<String?> getString(String key) async {
    final p = await _prefs;
    return p.getString(key);
  }

  static Future<int?> getInt(String key) async {
    final p = await _prefs;
    return p.getInt(key);
  }

  static Future<void> remove(String key) async {
    final p = await _prefs;
    await p.remove(key);
  }
}
