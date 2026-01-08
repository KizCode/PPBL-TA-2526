import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartState {
  CartState._();
  static final instance = CartState._();

  /// item: { id, name, price, quantity, notes }
  final List<Map<String, dynamic>> items = [];

  static const String _cartKey = 'cart_items';

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      items.clear();
      items.addAll(decoded.map((item) => Map<String, dynamic>.from(item)));
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(items);
    await prefs.setString(_cartKey, cartJson);
  }

  Future<void> addItem({
    required int id,
    required String name,
    required num price,
    int quantity = 1,
    String? notes,
  }) async {
    final idx = items.indexWhere((it) => it['id'] == id);
    if (idx >= 0) {
      items[idx]['quantity'] = (items[idx]['quantity'] as int) + quantity;
      if (notes != null && notes.trim().isNotEmpty) {
        items[idx]['notes'] = notes;
      }
    } else {
      items.add({
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'notes': notes,
      });
    }
    await _saveCart();
  }

  Future<void> updateNotes(int id, String? notes) async {
    final idx = items.indexWhere((it) => it['id'] == id);
    if (idx >= 0) items[idx]['notes'] = notes;
    await _saveCart();
  }

  Future<void> increaseQty(int id) async {
    final idx = items.indexWhere((it) => it['id'] == id);
    if (idx >= 0) items[idx]['quantity'] = (items[idx]['quantity'] as int) + 1;
    await _saveCart();
  }

  Future<void> decreaseQty(int id) async {
    final idx = items.indexWhere((it) => it['id'] == id);
    if (idx >= 0) {
      final q = items[idx]['quantity'] as int;
      if (q > 1)
        items[idx]['quantity'] = q - 1;
      else
        items.removeAt(idx);
    }
    await _saveCart();
  }

  Future<void> removeItem(int id) async {
    items.removeWhere((it) => it['id'] == id);
    await _saveCart();
  }

  Future<void> clear() async {
    items.clear();
    await _saveCart();
  }

  int get totalItems =>
      items.fold(0, (sum, it) => sum + (it['quantity'] as int));

  int get subtotal => items.fold(0, (sum, it) {
        final qty = it['quantity'] as int;
        final price = it['price'] as num;
        return sum + (price * qty).round();
      });
}
