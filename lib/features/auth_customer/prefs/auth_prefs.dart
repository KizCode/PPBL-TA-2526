import '../../../core/prefs/app_prefs.dart';

class AuthPrefs {
  static const String _keyLoggedIn = 'customer_logged_in';
  static const String _keyUserId = 'customer_user_id';
  static const String _keyUsername = 'customer_username';
  static const String _keyFullName = 'customer_full_name';
  static const String _keyEmail = 'customer_email';
  static const String _keyPhone = 'customer_phone';

  static Future<bool> isLoggedIn() async {
    return await AppPrefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    await AppPrefs.setBool(_keyLoggedIn, value);
  }

  static Future<void> setUserId(int id) async {
    await AppPrefs.setInt(_keyUserId, id);
  }

  static Future<int?> getUserId() async {
    return await AppPrefs.getInt(_keyUserId);
  }

  static Future<void> setUsername(String username) async {
    await AppPrefs.setString(_keyUsername, username);
  }

  static Future<String?> getUsername() async {
    return await AppPrefs.getString(_keyUsername);
  }

  static Future<void> setFullName(String fullName) async {
    await AppPrefs.setString(_keyFullName, fullName);
  }

  static Future<String?> getFullName() async {
    return await AppPrefs.getString(_keyFullName);
  }

  static Future<void> setEmail(String email) async {
    await AppPrefs.setString(_keyEmail, email);
  }

  static Future<String?> getEmail() async {
    return await AppPrefs.getString(_keyEmail);
  }

  static Future<void> setPhone(String phone) async {
    await AppPrefs.setString(_keyPhone, phone);
  }

  static Future<String?> getPhone() async {
    return await AppPrefs.getString(_keyPhone);
  }

  static Future<void> logout() async {
    await AppPrefs.setBool(_keyLoggedIn, false);
    await AppPrefs.remove(_keyUserId);
    await AppPrefs.remove(_keyUsername);
    await AppPrefs.remove(_keyFullName);
    await AppPrefs.remove(_keyEmail);
    await AppPrefs.remove(_keyPhone);
  }
}
