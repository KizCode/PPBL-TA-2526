import '../../materials/repositories/material_repository.dart';
import '../repositories/product_repository.dart';

class StockService {
  final _productRepo = ProductRepository();
  final _materialRepo = MaterialRepository();

  /// Check if product can be made with current material stock
  Future<bool> canMakeProduct(int productId, int quantity) async {
    final recipe = await _productRepo.recipeByProduct(productId);
    if (recipe.isEmpty) return false;

    final materials = await _materialRepo.all();

    for (final recipeItem in recipe) {
      final material = materials.where((m) => m.id == recipeItem.materialId).firstOrNull;
      if (material == null) return false;

      final requiredQty = recipeItem.qty * quantity;
      if (material.stock < requiredQty) {
        return false;
      }
    }

    return true;
  }

  /// Get available stock for a product based on materials
  Future<int> getAvailableStock(int productId) async {
    return await _productRepo.calculateAvailableStock(productId);
  }

  /// Deduct materials when product is sold
  Future<void> deductMaterials(int productId, int quantity) async {
    final recipe = await _productRepo.recipeByProduct(productId);
    if (recipe.isEmpty) return;

    for (final recipeItem in recipe) {
      final material = await _materialRepo.byId(recipeItem.materialId);
      if (material != null) {
        final newStock = material.stock - (recipeItem.qty * quantity);
        await _materialRepo.update(
          material.copyWith(stock: newStock >= 0 ? newStock : 0),
        );
      }
    }
  }

  /// Deduct materials for multiple products (from transaction)
  Future<void> deductMaterialsFromTransaction(List<Map<String, dynamic>> items) async {
    for (final item in items) {
      final menuId = item['menu_id'] as int?;
      final quantity = item['quantity'] as int?;

      if (menuId != null && quantity != null) {
        await deductMaterials(menuId, quantity);
      }
    }
  }

  /// Check if all items in cart can be fulfilled
  Future<Map<String, dynamic>> checkCartAvailability(List<Map<String, dynamic>> cartItems) async {
    final unavailableItems = <String>[];
    bool allAvailable = true;

    for (final item in cartItems) {
      final id = item['id'] as int;
      final name = item['name'] as String;
      final quantity = item['quantity'] as int;

      final canMake = await canMakeProduct(id, quantity);
      if (!canMake) {
        unavailableItems.add(name);
        allAvailable = false;
      }
    }

    return {
      'available': allAvailable,
      'unavailable_items': unavailableItems,
    };
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
