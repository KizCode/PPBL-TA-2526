import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/product_model.dart';

class ProductDb {
  static const table = 'products';

  static const createTableSql = '''
CREATE TABLE IF NOT EXISTS $table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  price INTEGER NOT NULL DEFAULT 0,
  stock INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
''';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insert(ProductModel product) async {
    final db = await _db;
    return db.insert(table, product.toMap());
  }

  Future<int> update(ProductModel product) async {
    final db = await _db;
    return db.update(
      table,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _db;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductModel>> all() async {
    final db = await _db;
    final rows = await db.query(table, orderBy: 'name ASC');
    return rows.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<ProductModel?> byId(int id) async {
    final db = await _db;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ProductModel.fromMap(rows.first);
  }

  Future<int> count() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    return (rows.first['c'] as int?) ?? 0;
  }
}
