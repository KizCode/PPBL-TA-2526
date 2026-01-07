import '../data/transaction_db.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _db = TransactionDb();

  Future<int> save(TransactionModel tx) => _db.insert(tx);
  Future<List<TransactionModel>> historyForUser(int userId) =>
      _db.byUser(userId);
  Future<int> setStatus(int id, String status) => _db.updateStatus(id, status);
}
