import 'package:flutter/material.dart';

import '../../cart_orders/prefs/cart_prefs.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = TransactionRepository();
  bool _loading = true;
  int? _userId;
  List<TransactionModel> _txs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = await CartPrefs.getActiveUser();

    List<TransactionModel> txs = const [];
    if (userId != null) {
      txs = await _repo.historyForUser(userId);
    }

    if (!mounted) return;
    setState(() {
      _userId = userId;
      _txs = txs;
      _loading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelian'),
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
            : _txs.isEmpty
            ? RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('Belum ada transaksi.')),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _txs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = _txs[index];
                    final date =
                        '${tx.createdAt.day.toString().padLeft(2, '0')}/'
                        '${tx.createdAt.month.toString().padLeft(2, '0')}/'
                        '${tx.createdAt.year} '
                        '${tx.createdAt.hour.toString().padLeft(2, '0')}:'
                        '${tx.createdAt.minute.toString().padLeft(2, '0')}';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaksi #${tx.id ?? '-'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text('Tanggal: $date'),
                            Text('Total: ${_formatRupiah(tx.totalAmount)}'),
                            Text('Metode: ${tx.paymentMethod}'),
                            Text('Status: ${tx.status}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
