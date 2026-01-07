import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../../materials/data/material_db.dart';
import '../data/product_db.dart';
import '../data/recipe_db.dart';
import '../models/product_model.dart';
import '../models/recipe_item_model.dart';

class ProductRepository {
  final ProductDb _productDb;
  final RecipeDb _recipeDb;
  final MaterialDb _materialDb;

  ProductRepository({
    ProductDb? productDb,
    RecipeDb? recipeDb,
    MaterialDb? materialDb,
  })  : _productDb = productDb ?? ProductDb(),
        _recipeDb = recipeDb ?? RecipeDb(),
        _materialDb = materialDb ?? MaterialDb();

  Future<List<ProductModel>> all() => _productDb.all();

  Future<int> count() => _productDb.count();

  Future<List<RecipeItemModel>> recipeByProduct(int productId) =>
      _recipeDb.byProduct(productId);

  Future<int> createWithRecipe({
    required String name,
    required int price,
    required List<RecipeItemModel> recipeItems,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now();

    return db.transaction((txn) async {
      final productId = await txn.insert(
        ProductDb.table,
        ProductModel(name: name, price: price, createdAt: now).toMap(),
      );

      for (final item in recipeItems) {
        await txn.insert(
          RecipeDb.table,
          RecipeItemModel(
            productId: productId,
            materialId: item.materialId,
            qty: item.qty,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return productId;
    });
  }

  Future<void> updateWithRecipe({
    required ProductModel product,
    required List<RecipeItemModel> recipeItems,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.update(
        ProductDb.table,
        product.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      await txn.delete(RecipeDb.table,
          where: 'product_id = ?', whereArgs: [product.id]);

      for (final item in recipeItems) {
        await txn.insert(
          RecipeDb.table,
          RecipeItemModel(
            productId: product.id!,
            materialId: item.materialId,
            qty: item.qty,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> delete(int id) => _productDb.deleteById(id).then((_) {});

  // Helper for UI: validate material exists
  Future<bool> materialExists(int materialId) async {
    final m = await _materialDb.byId(materialId);
    return m != null;
  }
}
