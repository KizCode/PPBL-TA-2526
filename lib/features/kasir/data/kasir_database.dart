import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../models/menu_item.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async => AppDatabase.instance.database;

  // Produk CRUD - menggunakan tabel products dari owner
  Future<List<MenuItem>> getAllProduk() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name');
    
    final items = <MenuItem>[];
    for (final row in rows) {
      final productId = row['id'] as int;
      final calculatedStock = await _calculateStock(productId);
      
      items.add(MenuItem.fromProductMap(row).copyWith(stock: calculatedStock));
    }
    
    return items;
  }

  // Calculate available stock from materials
  Future<int> _calculateStock(int productId) async {
    final db = await database;
    
    // Get recipe
    final recipe = await db.query(
      'product_materials',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    
    if (recipe.isEmpty) return 0;
    
    int minStock = 999999;
    for (final item in recipe) {
      final materialId = item['material_id'] as int;
      final qtyNeeded = (item['qty'] as num).toDouble();
      
      // Get material stock
      final materials = await db.query(
        'materials',
        where: 'id = ?',
        whereArgs: [materialId],
      );
      
      if (materials.isEmpty) return 0;
      
      final materialStock = (materials.first['stock'] as num).toDouble();
      final possible = (materialStock / qtyNeeded).floor();
      
      if (possible < minStock) {
        minStock = possible;
      }
    }
    
    return minStock == 999999 ? 0 : minStock;
  }

  Future<void> insertProduk(MenuItem p) async {
    final db = await database;
    await db.insert(
      'products',
      p.toProductMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduk(MenuItem p) async {
    final db = await database;
    await db.update('products', p.toProductMap(), where: 'id = ?', whereArgs: [p.numericId]);
  }

  Future<void> deleteProduk(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Initialize with dummy data if empty
  Future<void> initializeDummyData() async {
    final db = await database;
    
    // Cek apakah sudah ada data
    final productCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products')
    ) ?? 0;
    
    if (productCount > 0) {
      print('Dummy data already exists');
      return;
    }

    final now = DateTime.now().toIso8601String();

    // 1. Buat materials (bahan-bahan)
    final materials = [
      {'name': 'Kopi Espresso', 'unit': 'shot', 'stock': 100.0, 'created_at': now},
      {'name': 'Susu', 'unit': 'ml', 'stock': 5000.0, 'created_at': now},
      {'name': 'Coklat', 'unit': 'gram', 'stock': 2000.0, 'created_at': now},
      {'name': 'Green Tea Powder', 'unit': 'gram', 'stock': 1000.0, 'created_at': now},
      {'name': 'Air Panas', 'unit': 'ml', 'stock': 10000.0, 'created_at': now},
      {'name': 'Croissant', 'unit': 'pcs', 'stock': 50.0, 'created_at': now},
      {'name': 'Cream Cheese', 'unit': 'gram', 'stock': 1000.0, 'created_at': now},
      {'name': 'Graham Cracker', 'unit': 'gram', 'stock': 500.0, 'created_at': now},
      {'name': 'Gula', 'unit': 'gram', 'stock': 3000.0, 'created_at': now},
    ];

    final materialIds = <int>[];
    for (final material in materials) {
      final id = await db.insert('materials', material);
      materialIds.add(id);
    }

    // 2. Buat products (stock akan dihitung otomatis dari materials)
    final products = [
      {'name': 'Espresso', 'price': 15000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Cappuccino', 'price': 20000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Latte', 'price': 22000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Americano', 'price': 18000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Mocha', 'price': 25000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Green Tea Latte', 'price': 23000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Croissant', 'price': 12000, 'stock': 0, 'created_at': now, 'updated_at': now},
      {'name': 'Cheesecake', 'price': 28000, 'stock': 0, 'created_at': now, 'updated_at': now},
    ];

    final productIds = <int>[];
    for (final product in products) {
      final id = await db.insert('products', product);
      productIds.add(id);
    }

    // 3. Buat recipes (product_materials) - hubungan produk dengan bahan
    final recipes = [
      // Espresso (1 shot kopi)
      {'product_id': productIds[0], 'material_id': materialIds[0], 'qty': 1.0, 'created_at': now},
      
      // Cappuccino (1 shot kopi + 150ml susu)
      {'product_id': productIds[1], 'material_id': materialIds[0], 'qty': 1.0, 'created_at': now},
      {'product_id': productIds[1], 'material_id': materialIds[1], 'qty': 150.0, 'created_at': now},
      
      // Latte (1 shot kopi + 200ml susu)
      {'product_id': productIds[2], 'material_id': materialIds[0], 'qty': 1.0, 'created_at': now},
      {'product_id': productIds[2], 'material_id': materialIds[1], 'qty': 200.0, 'created_at': now},
      
      // Americano (1 shot kopi + 150ml air panas)
      {'product_id': productIds[3], 'material_id': materialIds[0], 'qty': 1.0, 'created_at': now},
      {'product_id': productIds[3], 'material_id': materialIds[4], 'qty': 150.0, 'created_at': now},
      
      // Mocha (1 shot kopi + 150ml susu + 30g coklat)
      {'product_id': productIds[4], 'material_id': materialIds[0], 'qty': 1.0, 'created_at': now},
      {'product_id': productIds[4], 'material_id': materialIds[1], 'qty': 150.0, 'created_at': now},
      {'product_id': productIds[4], 'material_id': materialIds[2], 'qty': 30.0, 'created_at': now},
      
      // Green Tea Latte (20g green tea + 200ml susu)
      {'product_id': productIds[5], 'material_id': materialIds[3], 'qty': 20.0, 'created_at': now},
      {'product_id': productIds[5], 'material_id': materialIds[1], 'qty': 200.0, 'created_at': now},
      
      // Croissant (1 pcs)
      {'product_id': productIds[6], 'material_id': materialIds[5], 'qty': 1.0, 'created_at': now},
      
      // Cheesecake (150g cream cheese + 50g graham cracker + 30g gula)
      {'product_id': productIds[7], 'material_id': materialIds[6], 'qty': 150.0, 'created_at': now},
      {'product_id': productIds[7], 'material_id': materialIds[7], 'qty': 50.0, 'created_at': now},
      {'product_id': productIds[7], 'material_id': materialIds[8], 'qty': 30.0, 'created_at': now},
    ];

    for (final recipe in recipes) {
      await db.insert('product_materials', recipe);
    }

    print('Dummy data initialized:');
    print('- ${materials.length} materials');
    print('- ${products.length} products');
    print('- ${recipes.length} recipe items');
  }

  // Transactional sell (simplified): reduce bahan based on resep
  Future<void> sellProduct(int produkId, int qty) async {
    final db = await database;
    await db.transaction((txn) async {
      // get resep rows for produk dari tabel product_materials
      final resepRows = await txn.query(
        'product_materials',
        where: 'product_id = ?',
        whereArgs: [produkId],
      );
      for (final r in resepRows) {
        final bahanId = r['material_id'] as int;
        final jumlahPer = (r['qty'] as num).toDouble();
        final needed = jumlahPer * qty;
        final bahanRows = await txn.query(
          'materials',
          where: 'id = ?',
          whereArgs: [bahanId],
        );
        if (bahanRows.isEmpty) {
          throw Exception('Bahan tidak ditemukan');
        }
        final stok = (bahanRows.first['stock'] as num).toDouble();
        if (stok < needed) {
          throw Exception('Stok bahan ${bahanRows.first['name']} kurang');
        }
        await txn.update(
          'materials',
          {'stock': stok - needed},
          where: 'id = ?',
          whereArgs: [bahanId],
        );
      }
    });
  }
}
