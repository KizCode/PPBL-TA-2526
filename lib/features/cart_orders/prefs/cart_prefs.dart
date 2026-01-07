import '../../../core/prefs/app_prefs.dart';

class CartPrefs {
  static const keyActiveUserId = 'cart.active_user_id';
  static Future<void> setActiveUser(int userId) =>
      AppPrefs.setInt(keyActiveUserId, userId);
  static Future<int?> getActiveUser() => AppPrefs.getInt(keyActiveUserId);

  static Future<void> clearActiveUser() => AppPrefs.remove(keyActiveUserId);
}
