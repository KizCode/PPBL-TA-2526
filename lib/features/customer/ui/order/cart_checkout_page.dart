import 'package:flutter/material.dart';
import 'dart:convert';
import 'cart_state.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../../core/db/app_database.dart';
import '../../../products/services/stock_service.dart';

enum PaymentMethod { qris, ewallet, mobileBanking, cash }

String rupiah(num value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
  }
  return 'Rp ${buf.toString()}';
}

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  final cart = CartState.instance;

  static const double taxRate = 0.10; // 10%
  static const double serviceRate = 0.05; // 5%
  PaymentMethod _method = PaymentMethod.qris;

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.subtotal;
    final tax = (subtotal * taxRate).round();
    final service = (subtotal * serviceRate).round();
    final total = subtotal + tax + service;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Keranjang & Checkout'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cart.items.map((it) {
                  final name = it['name']?.toString() ?? 'Menu';
                  final price = (it['price'] is num)
                      ? (it['price'] as num)
                      : num.tryParse(it['price']?.toString() ?? '0') ?? 0;
                  final qty = it['quantity'] as int? ?? 1;
                  return CartItemCard(
                    name: name,
                    priceText: rupiah(price),
                    quantity: qty,
                    onIncrease: () async {
                      await cart.increaseQty(it['id'] as int);
                      setState(() {});
                    },
                    onDecrease: () async {
                      await cart.decreaseQty(it['id'] as int);
                      setState(() {});
                    },
                    onRemove: () async {
                      await cart.removeItem(it['id'] as int);
                      setState(() {});
                    },
                  );
                }),
                const SizedBox(height: 12),
                _PriceSummaryCard(
                  subtotal: subtotal,
                  tax: tax,
                  service: service,
                  total: total,
                ),
                const SizedBox(height: 12),
                _PaymentMethodCard(
                  method: _method,
                  onChanged: (m) => setState(() => _method = m),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: cart.totalItems == 0
                      ? null
                      : () => _onConfirm(context, total),
                  child: const Text('Konfirmasi & Bayar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirm(BuildContext context, int total) async {
    // Validate stock before proceeding
    final stockService = StockService();
    final unavailableItems = <String>[];
    
    for (final item in cart.items) {
      final id = item['id'] as int;
      final name = item['name']?.toString() ?? 'Menu';
      final qty = item['quantity'] as int? ?? 1;
      
      final canMake = await stockService.canMakeProduct(id, qty);
      if (!canMake) {
        unavailableItems.add(name);
      }
    }
    
    if (unavailableItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Item berikut tidak bisa dibuat karena bahan tidak mencukupi:\n${unavailableItems.join(", ")}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    
    final methodText = switch (_method) {
      PaymentMethod.qris => 'QRIS',
      PaymentMethod.ewallet => 'E-Wallet',
      PaymentMethod.mobileBanking => 'Mobile Banking',
      PaymentMethod.cash => 'Tunai',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Konfirmasi Pembayaran',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Metode: $methodText'),
            const SizedBox(height: 4),
            Text('Total: ${rupiah(total)}'),
            const SizedBox(height: 12),
            if (_method == PaymentMethod.qris) ...[
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  color: Colors.black12,
                  child: const Center(child: Text('QRIS')),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Silakan scan QR untuk membayar.'),
            ] else if (_method == PaymentMethod.mobileBanking) ...[
              const Text('Upload bukti transfer (contoh tombol):'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contoh: buka file picker')),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
              ),
            ] else if (_method == PaymentMethod.cash) ...[
              const Text('Silakan bayar tunai di kasir.'),
            ] else ...[
              const Text('Lanjutkan pembayaran melalui E-Wallet.'),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.pop(context); // tutup modal
                  
                  final stockService = StockService();
                  final db = await AppDatabase.instance.database;
                  
                  // Reduce materials stock for each cart item using StockService
                  try {
                    for (final item in cart.items) {
                      final productId = item['id'] as int;
                      final qty = item['quantity'] as int;
                      
                      // Deduct materials using StockService
                      await stockService.deductMaterials(productId, qty);
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                    return;
                  }
                  
                  // Save transaction to database
                  try {
                    final items = cart.items.map((item) => {
                      'id': item['id'],
                      'name': item['name'],
                      'qty': item['quantity'],
                      'price': item['price'],
                    }).toList();
                    
                    final itemsJson = jsonEncode(items);
                    final totalAmount = cart.items.fold<int>(0, (sum, item) {
                      final price = (item['price'] as num).toInt();
                      final qty = item['quantity'] as int;
                      return sum + (price * qty);
                    });
                    
                    final paymentMethodStr = _method == PaymentMethod.qris 
                        ? 'QRIS' 
                        : _method == PaymentMethod.ewallet 
                            ? 'E-Wallet' 
                            : _method == PaymentMethod.mobileBanking 
                                ? 'Mobile Banking' 
                                : 'Tunai';
                    
                    await db.insert('transactions', {
                      'user_id': 1, // TODO: Get actual user ID from auth
                      'total_amount': totalAmount,
                      'payment_method': paymentMethodStr,
                      'status': 'paid',
                      'items_json': itemsJson,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error menyimpan transaksi: $e')),
                    );
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembayaran diproses')),
                  );
                  await cart.clear(); // kosongkan keranjang
                  if (!mounted) return;
                  Navigator.pop(context); // kembali ke halaman sebelumnya
                },
                child: const Text('Selesaikan'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final int subtotal;
  final int tax;
  final int service;
  final int total;

  const _PriceSummaryCard({
    required this.subtotal,
    required this.tax,
    required this.service,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Subtotal'),
              Text(rupiah(subtotal)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Pajak (10%)'),
              Text(rupiah(tax)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Biaya Layanan (5%)'),
              Text(rupiah(service)),
            ]),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  rupiah(total),
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onChanged;
  const _PaymentMethodCard({required this.method, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _radio(context, PaymentMethod.qris, 'QRIS'),
            _radio(context, PaymentMethod.ewallet, 'E-Wallet'),
            _radio(context, PaymentMethod.mobileBanking,
                'Mobile Banking (Upload Bukti Transfer)'),
            _radio(context, PaymentMethod.cash, 'Tunai (Bayar di Kasir)'),
          ],
        ),
      ),
    );
  }

  Widget _radio(BuildContext context, PaymentMethod value, String label) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: method,
      onChanged: (v) => onChanged(v!),
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
