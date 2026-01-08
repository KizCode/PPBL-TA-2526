class MenuItem {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.category = 'Makanan & Minuman',
    this.imageUrl = '',
    this.description = '',
  });

  // Factory constructor untuk membuat dari JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int? ?? 0,
      category: json['category'] as String? ?? 'Makanan & Minuman',
      imageUrl: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  // Factory constructor dari products table (owner)
  factory MenuItem.fromProductMap(Map<String, dynamic> m) {
    return MenuItem(
      id: m['id'] as int,
      name: m['name'] as String? ?? '',
      price: ((m['price'] as int?) ?? 0).toDouble(),
      stock: (m['stock'] as int?) ?? 0,
      category: 'Menu',
      imageUrl: '',
      description: '',
    );
  }

  // Method untuk convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // Copy with untuk update
  MenuItem copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    String? description,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}
