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

  /// Calculate available stock based on materials
  Future<int> calculateAvailableStock(int productId) async {
    final recipe = await _recipeDb.byProduct(productId);
    if (recipe.isEmpty) return 0;

    final materials = await _materialDb.all();
    
    int minStock = 999999;
    for (final recipeItem in recipe) {
      final material = materials.where((m) => m.id == recipeItem.materialId).firstOrNull;
      if (material == null) return 0;
      
      // Calculate how many products can be made from this material
      final possibleFromThisMaterial = (material.stock / recipeItem.qty).floor();
      
      // The minimum determines the actual available stock
      if (possibleFromThisMaterial < minStock) {
        minStock = possibleFromThisMaterial;
      }
    }
    
    return minStock == 999999 ? 0 : minStock;
  }

  /// Get products with calculated stock
  Future<List<ProductModel>> allWithStock() async {
    final products = await _productDb.all();
    final productsWithStock = <ProductModel>[];
    
    for (final product in products) {
      final calculatedStock = await calculateAvailableStock(product.id!);
      productsWithStock.add(product.copyWith(stock: calculatedStock));
    }
    
    return productsWithStock;
  }

  Future<int> createWithRecipe({
    required String name,
    required int price,
    String? imageUrl,
    required List<RecipeItemModel> recipeItems,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now();

    return db.transaction((txn) async {
      final productId = await txn.insert(
        ProductDb.table,
        ProductModel(
          name: name,
          price: price,
          stock: 0,
          imageUrl: imageUrl,
          createdAt: now,
        ).toMap(),
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
