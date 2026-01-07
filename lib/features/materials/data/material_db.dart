import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/material_model.dart';

class MaterialDb {
  static const table = 'materials';

  static const createTableSql = '''
CREATE TABLE IF NOT EXISTS $table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  unit TEXT NOT NULL,
  stock REAL NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
''';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insert(MaterialModel material) async {
    final db = await _db;
    return db.insert(table, material.toMap());
  }

  Future<int> update(MaterialModel material) async {
    final db = await _db;
    return db.update(
      table,
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _db;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MaterialModel>> all() async {
    final db = await _db;
    final rows = await db.query(table, orderBy: 'name ASC');
    return rows.map((e) => MaterialModel.fromMap(e)).toList();
  }

  Future<MaterialModel?> byId(int id) async {
    final db = await _db;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return MaterialModel.fromMap(rows.first);
  }

  Future<int> count() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<double> sumStock() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT SUM(stock) AS s FROM $table');
    final v = rows.first['s'];
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
