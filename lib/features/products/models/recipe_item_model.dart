class RecipeItemModel {
  final int? id;
  final int productId;
  final int materialId;
  final double qty;

  const RecipeItemModel({
    this.id,
    required this.productId,
    required this.materialId,
    required this.qty,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'material_id': materialId,
      'qty': qty,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static RecipeItemModel fromMap(Map<String, Object?> map) {
    return RecipeItemModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      materialId: map['material_id'] as int,
      qty: _toDouble(map['qty']),
    );
  }

  static double _toDouble(Object? v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
