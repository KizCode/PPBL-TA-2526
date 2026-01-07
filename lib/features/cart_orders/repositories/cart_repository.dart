import '../data/cart_db.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final _db = CartDb();

  Future<int> addItem(CartItemModel item) => _db.add(item);
  Future<List<CartItemModel>> cartForUser(int userId) => _db.byUser(userId);
  Future<int> changeQty(int id, int qty) => _db.updateQty(id, qty);
  Future<int> removeItem(int id) => _db.remove(id);
  Future<int> clearCart(int userId) => _db.clearForUser(userId);
}
