import '../../../core/prefs/app_prefs.dart';

class PaymentsPrefs {
  static const keyLastMethod = 'payments.last_method';
  static const keyLastStatus = 'payments.last_status';
  static const keyLastTransactionId = 'payments.last_tx_id';

  static Future<void> setLastMethod(String method) =>
      AppPrefs.setString(keyLastMethod, method);
  static Future<void> setLastStatus(String status) =>
      AppPrefs.setString(keyLastStatus, status);
  static Future<String?> getLastMethod() => AppPrefs.getString(keyLastMethod);
  static Future<String?> getLastStatus() => AppPrefs.getString(keyLastStatus);

  static Future<void> setLastTransactionId(int txId) =>
      AppPrefs.setInt(keyLastTransactionId, txId);
  static Future<int?> getLastTransactionId() =>
      AppPrefs.getInt(keyLastTransactionId);
}
