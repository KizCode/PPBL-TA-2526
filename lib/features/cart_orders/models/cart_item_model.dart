class CartItemModel {
  final int? id;
  final int userId;
  final int menuId;
  final String menuName;
  final int quantity;
  final int price; // store in smallest currency unit (e.g. cents)
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CartItemModel({
    this.id,
    required this.userId,
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.price,
    this.note,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get subtotal => price * quantity;

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': userId,
    'menu_id': menuId,
    'menu_name': menuName,
    'quantity': quantity,
    'price': price,
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  static CartItemModel fromMap(Map<String, Object?> m) => CartItemModel(
    id: m['id'] as int?,
    userId: m['user_id'] as int,
    menuId: m['menu_id'] as int,
    menuName: m['menu_name'] as String,
    quantity: m['quantity'] as int,
    price: m['price'] as int,
    note: m['note'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: m['updated_at'] != null
        ? DateTime.parse(m['updated_at'] as String)
        : null,
  );
}
