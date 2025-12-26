import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../../../services/db_service.dart';

class CategoryProvider with ChangeNotifier {
  final DBService _db = DBService();
  
  List<Category> _categories = [];
  bool _isLoaded = false;

  List<Category> get categories => _categories;
  List<Category> get activeCategories => _categories.where((c) => c.isActive).toList();

  Future<void> loadCategories() async {
    if (_isLoaded) return;
    _isLoaded = true;
    
    _categories = await _db.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category cat) async {
    _categories.add(cat);
    _categories.sort((a, b) {
      final orderCmp = a.sortOrder.compareTo(b.sortOrder);
      return orderCmp != 0 ? orderCmp : a.name.compareTo(b.name);
    });
    notifyListeners();
    await _db.insertCategory(cat);
  }

  Future<void> updateCategory(Category cat) async {
    final idx = _categories.indexWhere((c) => c.id == cat.id);
    if (idx >= 0) {
      _categories[idx] = cat;
      _categories.sort((a, b) {
        final orderCmp = a.sortOrder.compareTo(b.sortOrder);
        return orderCmp != 0 ? orderCmp : a.name.compareTo(b.name);
      });
      notifyListeners();
    }
    await _db.updateCategory(cat);
  }

  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    await _db.deleteCategory(id);
  }

  void refresh() {
    _isLoaded = false;
    loadCategories();
  }
}
