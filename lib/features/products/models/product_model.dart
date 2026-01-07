class ProductModel {
  final int? id;
  final String name;
  final int price;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static ProductModel fromMap(Map<String, Object?> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    int? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
