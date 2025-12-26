import 'package:flutter/foundation.dart';
import '../models/ingredient.dart';
import '../../../services/db_service.dart';

class IngredientProvider with ChangeNotifier {
  final DBService _db = DBService();
  
  List<Ingredient> _ingredients = [];
  bool _isLoaded = false;

  List<Ingredient> get ingredients => _ingredients;
  List<Ingredient> get lowStockIngredients => _ingredients.where((i) => i.isLowStock).toList();
  int get lowStockCount => lowStockIngredients.length;

  Future<void> loadIngredients() async {
    if (_isLoaded) return;
    _isLoaded = true;
    
    _ingredients = await _db.getIngredients();
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ing) async {
    _ingredients.add(ing);
    _ingredients.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    await _db.insertIngredient(ing);
  }

  Future<void> updateIngredient(Ingredient ing) async {
    final idx = _ingredients.indexWhere((i) => i.id == ing.id);
    if (idx >= 0) {
      _ingredients[idx] = ing;
      notifyListeners();
    }
    await _db.updateIngredient(ing);
  }

  Future<void> deleteIngredient(int id) async {
    _ingredients.removeWhere((i) => i.id == id);
    notifyListeners();
    await _db.deleteIngredient(id);
  }

  Future<void> addStock(int id, double quantity) async {
    final idx = _ingredients.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final newQty = _ingredients[idx].quantity + quantity;
      final updated = Ingredient(
        id: _ingredients[idx].id,
        name: _ingredients[idx].name,
        unit: _ingredients[idx].unit,
        quantity: newQty,
        minStock: _ingredients[idx].minStock,
        price: _ingredients[idx].price,
        lastUpdated: DateTime.now(),
      );
      _ingredients[idx] = updated;
      notifyListeners();
      await _db.updateIngredientQuantity(id, newQty);
    }
  }

  Future<void> reduceStock(int id, double quantity) async {
    final idx = _ingredients.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final newQty = (_ingredients[idx].quantity - quantity).clamp(0.0, double.infinity);
      final updated = Ingredient(
        id: _ingredients[idx].id,
        name: _ingredients[idx].name,
        unit: _ingredients[idx].unit,
        quantity: newQty,
        minStock: _ingredients[idx].minStock,
        price: _ingredients[idx].price,
        lastUpdated: DateTime.now(),
      );
      _ingredients[idx] = updated;
      notifyListeners();
      await _db.updateIngredientQuantity(id, newQty);
    }
  }

  void refresh() {
    _isLoaded = false;
    loadIngredients();
  }
}
