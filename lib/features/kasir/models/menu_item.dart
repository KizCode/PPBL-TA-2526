class MenuItem {
  final String id;
  String name;
  double price;
  int stock;
  String description;
  String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.description = '',
    this.imageUrl = '',
  });

  // For numeric ID from products table
  int get numericId => int.tryParse(id) ?? 0;

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  // SQLite mapping for old kasir table
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> m) {
    return MenuItem(
      id: m['id'] as String? ?? '',
      name: m['name'] as String? ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0.0,
      description: m['description'] as String? ?? '',
      imageUrl: m['imageUrl'] as String? ?? '',
    );
  }

  // Mapping to/from products table (owner)
  Map<String, dynamic> toProductMap() {
    return {
      'name': name,
      'price': price.toInt(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory MenuItem.fromProductMap(Map<String, dynamic> m) {
    return MenuItem(
      id: (m['id'] as int).toString(),
      name: m['name'] as String? ?? '',
      price: ((m['price'] as int?) ?? 0).toDouble(),
      stock: (m['stock'] as int?) ?? 0,
      description: '',
      imageUrl: '',
    );
  }
}
