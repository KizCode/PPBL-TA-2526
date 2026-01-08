import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import '../models/menu_item.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  // Load data dari database products (owner)
  Future<void> loadMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query('products', orderBy: 'name');
      
      final items = <MenuItem>[];
      for (final row in rows) {
        final productId = row['id'] as int;
        final calculatedStock = await _calculateStock(db, productId);
        
        items.add(MenuItem.fromProductMap(row).copyWith(stock: calculatedStock));
      }
      
      _menuItems = items;
    } catch (e) {
      // Handle error
      _menuItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate available stock from materials
  Future<int> _calculateStock(Database db, int productId) async {
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

  // Get by ID
  MenuItem? getMenuItemById(int id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get by category
  List<MenuItem> getMenuItemsByCategory(String category) {
    if (category == 'Semua') return _menuItems;
    return _menuItems.where((item) => item.category == category).toList();
  }
}
