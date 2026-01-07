class MaterialModel {
  final int? id;
  final String name;
  final String unit; // gr, ml, pcs
  final double stock;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MaterialModel({
    this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static MaterialModel fromMap(Map<String, Object?> map) {
    return MaterialModel(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      unit: (map['unit'] as String?) ?? 'pcs',
      stock: _toDouble(map['stock']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  static double _toDouble(Object? v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  MaterialModel copyWith({
    int? id,
    String? name,
    String? unit,
    double? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
