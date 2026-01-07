import 'package:flutter/material.dart';

import 'dart:convert';

import '../models/cart_item_model.dart';
import '../prefs/cart_prefs.dart';
import '../repositories/cart_repository.dart';
import '../../payments_history/models/transaction_model.dart';
import '../../payments_history/prefs/payments_prefs.dart';
import '../../payments_history/repositories/transaction_repository.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cartRepo = CartRepository();
  final _txRepo = TransactionRepository();

  bool _loading = true;
  bool _submitting = false;
  int? _userId;
  List<CartItemModel> _items = const [];
  String _method = 'cash';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = await CartPrefs.getActiveUser();
    final lastMethod = await PaymentsPrefs.getLastMethod();

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _userId = null;
        _items = const [];
        _method = lastMethod ?? 'cash';
        _loading = false;
      });
      return;
    }

    final items = await _cartRepo.cartForUser(userId);
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _items = items;
      _method = lastMethod ?? 'cash';
      _loading = false;
    });
  }

  int get _total => _items.fold(0, (sum, i) => sum + i.subtotal);

  String _formatRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buffer.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  String _buildItemsJson(List<CartItemModel> items) {
    final list = items
        .map(
          (i) => {
            'menu_id': i.menuId,
            'menu_name': i.menuName,
            'quantity': i.quantity,
            'price': i.price,
          },
        )
        .toList();
    return jsonEncode(list);
  }

  Future<void> _createTransactionAndContinue() async {
    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu.')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await PaymentsPrefs.setLastMethod(_method);
      await PaymentsPrefs.setLastStatus('pending');

      final txId = await _txRepo.save(
        TransactionModel(
          userId: _userId!,
          totalAmount: _total,
          paymentMethod: _method,
          status: 'pending',
          itemsJson: _buildItemsJson(_items),
        ),
      );

      await PaymentsPrefs.setLastTransactionId(txId);
      await _cartRepo.clearCart(_userId!);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/payment');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _userId == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Silakan login dulu.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (r) => false,
                      ),
                      child: const Text('Ke Login'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Ringkasan Pesanan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_items.isEmpty)
                    const Text('Keranjang kosong.')
                  else
                    ..._items.map(
                      (i) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${i.menuName} x ${i.quantity}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(_formatRupiah(i.subtotal)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('Total')),
                              Text(
                                _formatRupiah(_total),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Metode Pembayaran',
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _method,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'cash',
                                    child: Text('Cash'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'qris',
                                    child: Text('QRIS'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'transfer',
                                    child: Text('Transfer'),
                                  ),
                                ],
                                onChanged: _submitting
                                    ? null
                                    : (v) {
                                        if (v == null) return;
                                        setState(() => _method = v);
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _submitting
                                ? null
                                : _createTransactionAndContinue,
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Lanjut Pembayaran'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
