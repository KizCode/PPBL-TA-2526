import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/transaction_model.dart';

class TransactionDb {
  static const table = 'transactions';
  static const createTableSql =
      '''
  CREATE TABLE IF NOT EXISTS $table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    total_amount INTEGER NOT NULL,
    payment_method TEXT NOT NULL,
    status TEXT NOT NULL,
    items_json TEXT NOT NULL,
    created_at TEXT NOT NULL
  )
  ''';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insert(TransactionModel tx) async {
    final db = await _db;
    return db.insert(table, tx.toMap());
  }

  Future<List<TransactionModel>> byUser(int userId) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _db;
    return db.update(
      table,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
