// Model untuk Stok Bahan Baku
class Ingredient {
  final int? id;
  final String name;
  final String unit; // kg, liter, pcs, dll
  final double quantity;
  final double minStock; // Minimum stock alert
  final int price; // Harga per unit
  final DateTime lastUpdated;

  Ingredient({
    this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minStock,
    required this.price,
    required this.lastUpdated,
  });

  bool get isLowStock => quantity <= minStock;

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    id: map['id'] as int?,
    name: map['name'] as String,
    unit: map['unit'] as String,
    quantity: map['quantity'] as double,
    minStock: map['minStock'] as double,
    price: map['price'] as int,
    lastUpdated: DateTime.parse(map['lastUpdated'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'unit': unit,
    'quantity': quantity,
    'minStock': minStock,
    'price': price,
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}
