import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/recipe_item_model.dart';

class RecipeDb {
  static const table = 'product_materials';

  static const createTableSql = '''
CREATE TABLE IF NOT EXISTS $table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  material_id INTEGER NOT NULL,
  qty REAL NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE(product_id, material_id),
  FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY(material_id) REFERENCES materials(id) ON DELETE RESTRICT
)
''';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<RecipeItemModel>> byProduct(int productId) async {
    final db = await _db;
    final rows = await db.query(
      table,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'id ASC',
    );
    return rows.map((e) => RecipeItemModel.fromMap(e)).toList();
  }

  Future<void> replaceForProduct(int productId, List<RecipeItemModel> items) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(table, where: 'product_id = ?', whereArgs: [productId]);
      for (final item in items) {
        await txn.insert(
          table,
          item.copyWithProduct(productId).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}

extension _RecipeItemCopy on RecipeItemModel {
  RecipeItemModel copyWithProduct(int productId) {
    return RecipeItemModel(
      id: id,
      productId: productId,
      materialId: materialId,
      qty: qty,
    );
  }
}
