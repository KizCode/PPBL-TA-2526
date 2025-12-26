// Model untuk Kategori Menu
class Category {
  final int? id;
  final String name;
  final String description;
  final String icon; // Icon name atau emoji
  final int sortOrder;
  final bool isActive;

  Category({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'] as int?,
    name: map['name'] as String,
    description: map['description'] as String,
    icon: map['icon'] as String,
    sortOrder: map['sortOrder'] as int,
    isActive: (map['isActive'] as int) == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'sortOrder': sortOrder,
    'isActive': isActive ? 1 : 0,
  };
}
