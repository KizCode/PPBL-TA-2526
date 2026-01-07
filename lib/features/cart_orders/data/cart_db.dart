import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/cart_item_model.dart';

class CartDb {
  static const table = 'cart_items';
  static const createTableSql =
      '''
  CREATE TABLE IF NOT EXISTS $table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    menu_id INTEGER NOT NULL,
    menu_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    price INTEGER NOT NULL,
    note TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT
  )
  ''';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> add(CartItemModel item) async {
    final db = await _db;
    return db.insert(table, item.toMap());
  }

  Future<List<CartItemModel>> byUser(int userId) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<int> updateQty(int id, int qty) async {
    final db = await _db;
    return db.update(
      table,
      {'quantity': qty, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> remove(int id) async {
    final db = await _db;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearForUser(int userId) async {
    final db = await _db;
    return db.delete(table, where: 'user_id = ?', whereArgs: [userId]);
  }
}
