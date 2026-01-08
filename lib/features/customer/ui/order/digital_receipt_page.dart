
// lib/pages/order/digital_receipt_page.dart
import 'package:flutter/material.dart';

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

class DigitalReceiptPage extends StatelessWidget {
  /// Struktur data struk:
  /// {
  ///   'invoiceId': String,
  ///   'storeName': String,
  ///   'storeAddress': String,
  ///   'dateTime': String,             // contoh: '27 Oktober 2025, 14:30 WIB'
  ///   'items': List<Map>{'name': String, 'qty': int, 'price': int},
  ///   'taxRate': double,              // default 0.10 (10%)
  ///   'serviceRate': double,          // default 0.05 (5%)
  ///   'paymentMethod': String,        // contoh: 'QRIS'
  ///   'tableNo': String?,             // contoh: 'Meja 07'
  /// }
  final Map<String, dynamic> receipt;
  const DigitalReceiptPage({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    // Ambil data
    final invoiceId = receipt['invoiceId']?.toString() ?? '-';
    final storeName = receipt['storeName']?.toString() ?? 'Cafe';
    final storeAddress = receipt['storeAddress']?.toString() ?? '-';
    final dateTime = receipt['dateTime']?.toString() ?? '-';
    final items = (receipt['items'] as List?) ?? const [];
    final taxRate = (receipt['taxRate'] as double?) ?? 0.10;
    final serviceRate = (receipt['serviceRate'] as double?) ?? 0.05;
    final paymentMethod = receipt['paymentMethod']?.toString() ?? '-';
    final tableNo = receipt['tableNo']?.toString(); // boleh null

    // Hitung subtotal/tax/service/total
    final subtotal = items.fold<int>(0, (sum, it) {
      final p = (it['price'] is num) ? (it['price'] as num).round() : 0;
      final q = (it['qty'] as int?) ?? 1;
      return sum + (p * q);
    });
    final tax = (subtotal * taxRate).round();
    final service = (subtotal * serviceRate).round();
    final total = subtotal + tax + service;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Digital'),
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Bagikan',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bagikan struk (simulasi)')),
              );
              // TODO: integrasi share_plus atau buat PDF lalu bagikan
            },
          ),
          IconButton(
            tooltip: 'Unduh',
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unduh struk (simulasi)')),
              );
              // TODO: export ke PDF (package: pdf) lalu simpan (path_provider + permission_handler)
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header "Struk Pembayaran"
                  const Text('Struk Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('ID Transaksi: $invoiceId',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 10),
                  const Divider(),

                  // Info toko
                  Text(storeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(storeAddress),
                  const SizedBox(height: 4),
                  Text(dateTime),
                  const SizedBox(height: 10),
                  const Divider(),

                  // Daftar item
                  const Text('Item Pesanan',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ...items.map((it) {
                    final name = it['name']?.toString() ?? 'Item';
                    final qty = (it['qty'] as int?) ?? 1;
                    final price = (it['price'] is num) ? (it['price'] as num).round() : 0;
                    final lineTotal = price * qty;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$name x $qty'),
                          Text(rupiah(lineTotal)),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  // Subtotal, pajak, layanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(rupiah(subtotal)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pajak (${(taxRate * 100).toStringAsFixed(0)}%)'),
                      Text(rupiah(tax)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Biaya Layanan (${(serviceRate * 100).toStringAsFixed(0)}%)'),
                      Text(rupiah(service)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        rupiah(total),
                        style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Metode bayar & no meja
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran'),
                      Text(paymentMethod),
                    ],
                  ),
                  if (tableNo != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nomor Meja'),
                        Text(tableNo),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Text(
                    'Terima kasih telah memesan di Cafe Order!',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
