class TransactionModel {
  final int? id;
  final int userId;
  final int totalAmount; // cents
  final String paymentMethod; // e.g. 'cash', 'qris'
  final String status; // e.g. 'pending', 'paid', 'cancelled'
  final String itemsJson; // serialized cart items
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.itemsJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
    'id': id,
    'user_id': userId,
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'status': status,
    'items_json': itemsJson,
    'created_at': createdAt.toIso8601String(),
  };

  static TransactionModel fromMap(Map<String, Object?> m) => TransactionModel(
    id: m['id'] as int?,
    userId: m['user_id'] as int,
    totalAmount: m['total_amount'] as int,
    paymentMethod: m['payment_method'] as String,
    status: m['status'] as String,
    itemsJson: m['items_json'] as String,
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}
