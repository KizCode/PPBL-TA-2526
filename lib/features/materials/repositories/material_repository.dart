import '../data/material_db.dart';
import '../models/material_model.dart';

class MaterialRepository {
  final MaterialDb _db;
  MaterialRepository({MaterialDb? db}) : _db = db ?? MaterialDb();

  Future<List<MaterialModel>> all() => _db.all();

  Future<MaterialModel?> byId(int id) => _db.byId(id);

  Future<int> create({
    required String name,
    required String unit,
    required double stock,
  }) {
    final now = DateTime.now();
    return _db.insert(
      MaterialModel(name: name, unit: unit, stock: stock, createdAt: now),
    );
  }

  Future<void> update(MaterialModel material) async {
    await _db.update(material.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(int id) async {
    await _db.deleteById(id);
  }

  Future<int> count() => _db.count();

  Future<double> sumStock() => _db.sumStock();
}
