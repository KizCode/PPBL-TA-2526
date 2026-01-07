import '../../../core/prefs/app_prefs.dart';

class OwnerAuthPrefs {
  static const keyLoggedIn = 'owner_logged_in';
  static const keyEmail = 'owner_email';

  static Future<void> setLogin(String email) async {
    await AppPrefs.setBool(keyLoggedIn, true);
    await AppPrefs.setString(keyEmail, email);
  }

  static Future<void> logout() async {
    await AppPrefs.setBool(keyLoggedIn, false);
    await AppPrefs.remove(keyEmail);
  }

  static Future<bool> isLoggedIn() async {
    return await AppPrefs.getBool(keyLoggedIn) ?? false;
  }

  static Future<String?> getEmail() async {
    return await AppPrefs.getString(keyEmail);
  }
}
