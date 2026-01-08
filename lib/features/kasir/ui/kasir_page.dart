import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../data/kasir_database.dart';
import '../models/menu_item.dart';
import '../widgets/menu_card.dart';
import '../../../core/db/app_database.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final List<MenuItem> _menu = [];
  final Map<String, int> _cart = {};
  String _paymentMethod = 'Tunai';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initialize dummy data if needed
    await DatabaseHelper.instance.initializeDummyData();
    await _loadProduk();
  }

  Future<void> _loadProduk() async {
    final list = await DatabaseHelper.instance.getAllProduk();
    setState(() {
      _menu.clear();
      _menu.addAll(list);
    });
  }

  // Kasir hanya bisa tambah ke keranjang, tidak bisa edit/delete produk
  // Edit/delete produk adalah domain owner

  void _addToCart(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      if (!_cart.containsKey(id)) return;
      final q = _cart[id]! - 1;
      if (q <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = q;
      }
    });
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0.00', 'id_ID');
    return formatter.format(price);
  }

  double get _total {
    double t = 0;
    for (final e in _cart.entries) {
      final menu = _menu.firstWhere(
        (m) => m.id == e.key,
        orElse: () => MenuItem(id: '', name: '', price: 0),
      );
      t += menu.price * e.value;
    }
    return t;
  }

  Future<void> _saveTransaction(String paymentMethod) async {
    // Prepare items JSON
    final items = _cart.entries.map((entry) {
      final menu = _menu.firstWhere(
        (m) => m.id == entry.key,
        orElse: () => MenuItem(id: '', name: '', price: 0),
      );
      return {
        'id': menu.numericId,
        'name': menu.name,
        'qty': entry.value,
        'price': menu.price,
      };
    }).toList();

    final itemsJson = jsonEncode(items);
    final db = await AppDatabase.instance.database;

    await db.insert('transactions', {
      'user_id': 0, // Kasir tidak punya user_id, gunakan 0
      'total_amount': _total.toInt(),
      'payment_method': paymentMethod,
      'status': 'paid',
      'items_json': itemsJson,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  void _pay() {
    if (_cart.isEmpty) return;

    if (_paymentMethod == 'Tunai') {
      final cashCtl = TextEditingController();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pembayaran Tunai'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: Rp ${_formatPrice(_total)}'),
              const SizedBox(height: 8),
              TextField(
                controller: cashCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah diterima'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final paid = double.tryParse(cashCtl.text.trim()) ?? 0.0;
                if (paid < _total) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uang diterima kurang')),
                  );
                  return;
                }
                final change = paid - _total;
                
                // Tutup dialog pembayaran
                Navigator.pop(dialogContext);
                
                // Tunggu sebentar agar dialog tertutup
                await Future.delayed(const Duration(milliseconds: 100));
                
                if (!mounted) return;
                
                // Reduce materials stock for each cart item
                try {
                  for (final entry in _cart.entries) {
                    final productId = int.tryParse(entry.key) ?? 0;
                    await DatabaseHelper.instance.sellProduct(
                      productId,
                      entry.value,
                    );
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
                  await _saveTransaction('Tunai');
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error menyimpan transaksi: $e')),
                  );
                }
                
                // Clear cart
                setState(() {
                  _cart.clear();
                });
                
                // Reload menu to update stock
                await _loadProduk();
                
                // Tampilkan dialog kembalian
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Selesai'),
                    content: Text('Kembalian: Rp ${_formatPrice(change)}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Bayar'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Bayar via $_paymentMethod'),
          content: Text(
            'Total: Rp ${_total.toStringAsFixed(0)}\nLanjut bayar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Tutup dialog konfirmasi
                Navigator.pop(dialogContext);
                
                // Tunggu sebentar
                await Future.delayed(const Duration(milliseconds: 100));
                
                if (!mounted) return;
                
                // Reduce materials stock for each cart item
                try {
                  for (final entry in _cart.entries) {
                    final productId = int.tryParse(entry.key) ?? 0;
                    await DatabaseHelper.instance.sellProduct(
                      productId,
                      entry.value,
                    );
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
                  await _saveTransaction(_paymentMethod);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error menyimpan transaksi: $e')),
                  );
                }
                
                // Clear cart
                setState(() {
                  _cart.clear();
                });
                
                // Reload menu to update stock
                await _loadProduk();
                
                // Tampilkan snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran berhasil')),
                );
              },
              child: const Text('Bayar'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPaymentPanel() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Keranjang kosong'))
                  : ListView(
                      children: _cart.entries.map((e) {
                        final menu = _menu.firstWhere(
                          (m) => m.id == e.key,
                          orElse: () =>
                              MenuItem(id: '', name: 'Unknown', price: 0),
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(menu.name),
                          subtitle: Text('Rp ${_formatPrice(menu.price)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeFromCart(e.key),
                              ),
                              Text('${e.value}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _addToCart(e.key),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const Divider(),
            Text(
              'Total Bayaran: Rp ${_formatPrice(_total)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 6),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              items: const [
                DropdownMenuItem(value: 'Tunai', child: Text('Tunai')),
                DropdownMenuItem(
                  value: 'Kartu/Debit',
                  child: Text('Kartu/Debit'),
                ),
                DropdownMenuItem(value: 'QR', child: Text('QRis')),
              ],
              onChanged: (v) => setState(() {
                _paymentMethod = v ?? 'Tunai';
              }),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _pay, child: const Text('Bayar')),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _cart.clear();
                });
              },
              child: const Text('Batalkan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cafeSync — Kasir'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isNarrow = w < 800;
            if (isNarrow) {
              // Mobile / narrow: show vertical list (menu stacked top-to-bottom)
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: _menu.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      padding: const EdgeInsets.only(bottom: 12),
                      itemBuilder: (context, i) {
                        final m = _menu[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: MenuCard(
                            item: m,
                            onAddToCart: () => _addToCart(m.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 360,
                    width: double.infinity,
                    child: _buildPaymentPanel(),
                  ),
                ],
              );
            }

            // Wide screens: two-column layout
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _menu.length,
                    itemBuilder: (context, i) {
                      final m = _menu[i];
                      return MenuCard(
                        item: m,
                        onAddToCart: () => _addToCart(m.id),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(width: 360, child: _buildPaymentPanel()),
              ],
            );
          },
        ),
      ),

    );
  }
}
