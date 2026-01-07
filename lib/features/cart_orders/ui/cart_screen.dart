import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../prefs/cart_prefs.dart';
import '../repositories/cart_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _repo = CartRepository();

  int? _userId;
  bool _loading = true;
  List<CartItemModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = await CartPrefs.getActiveUser();
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _userId = null;
        _items = const [];
        _loading = false;
      });
      return;
    }

    final items = await _repo.cartForUser(userId);
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _items = items;
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

  Future<void> _changeQty(CartItemModel item, int newQty) async {
    if (item.id == null) return;
    if (newQty < 1) return;
    await _repo.changeQty(item.id!, newQty);
    await _load();
  }

  Future<void> _removeItem(CartItemModel item) async {
    if (item.id == null) return;
    await _repo.removeItem(item.id!);
    await _load();
  }

  void _goCheckout() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong.')));
      return;
    }
    Navigator.pushNamed(context, '/checkout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
            : RefreshIndicator(
                onRefresh: _load,
                child: _items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Keranjang kosong.')),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.menuName,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${_formatRupiah(item.price)} x ${item.quantity}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus',
                                        onPressed: () => _removeItem(item),
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () =>
                                            _changeQty(item, item.quantity - 1),
                                        child: const Text('-'),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.quantity.toString(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        onPressed: () =>
                                            _changeQty(item, item.quantity + 1),
                                        child: const Text('+'),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatRupiah(item.subtotal),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total'),
                    Text(
                      _formatRupiah(_total),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: (_loading || _items.isEmpty) ? null : _goCheckout,
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
