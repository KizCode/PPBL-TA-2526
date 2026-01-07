import 'package:flutter/material.dart';

import '../../cart_orders/prefs/cart_prefs.dart';
import '../models/transaction_model.dart';
import '../prefs/payments_prefs.dart';
import '../repositories/transaction_repository.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _repo = TransactionRepository();

  bool _loading = true;
  bool _paying = false;
  int? _userId;
  TransactionModel? _pending;
  String? _lastMethod;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final userId = await CartPrefs.getActiveUser();
    final lastMethod = await PaymentsPrefs.getLastMethod();
    final lastTxId = await PaymentsPrefs.getLastTransactionId();

    TransactionModel? pending;
    if (userId != null) {
      final history = await _repo.historyForUser(userId);

      if (lastTxId != null) {
        for (final t in history) {
          if (t.id == lastTxId && t.status == 'pending') {
            pending = t;
            break;
          }
        }
      }

      pending ??= () {
        for (final t in history) {
          if (t.status == 'pending') return t;
        }
        return null;
      }();
    }

    if (!mounted) return;
    setState(() {
      _userId = userId;
      _pending = (pending?.status == 'pending') ? pending : null;
      _lastMethod = lastMethod;
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

  Future<void> _payNow() async {
    final tx = _pending;
    if (tx?.id == null) return;

    setState(() => _paying = true);
    try {
      await _repo.setStatus(tx!.id!, 'paid');
      await PaymentsPrefs.setLastStatus('paid');
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/history', (r) => false);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
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
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Metode: ${_lastMethod ?? '-'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if (_pending == null)
                              const Text(
                                'Tidak ada transaksi pending. Buat pesanan dari Checkout.',
                              )
                            else ...[
                              Text(
                                'Total: ${_formatRupiah(_pending!.totalAmount)}',
                              ),
                              Text('Status: ${_pending!.status}'),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _paying
                                    ? null
                                    : (_pending == null)
                                    ? null
                                    : _payNow,
                                child: _paying
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Bayar Sekarang'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/history',
                        (r) => false,
                      ),
                      child: const Text('Lihat Riwayat'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
