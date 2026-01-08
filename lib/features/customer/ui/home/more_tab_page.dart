// lib/pages/home/more_tab_page.dart
import 'package:flutter/material.dart';
import '../order/order_tracking_page.dart';
import '../order/digital_receipt_page.dart';
import 'settings_page.dart';

class MoreTabPage extends StatelessWidget {
  const MoreTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);

    // Contoh data dummy (ganti sesuai backend kamu nanti):
    final sampleOrder = {
      'id': 'ORD-20251210-001',
      'status': 'diproses', // 'menunggu' | 'diproses' | 'siap' | 'selesai'
      'estimate': '15 - 20 menit',
      'items': [
        {'name': 'Kopi Susu Gula Aren', 'qty': 2},
        {'name': 'Roti Bakar Keju', 'qty': 1},
        {'name': 'Teh Tarik Dingin', 'qty': 1},
      ],
    };

    final sampleReceipt = {
      'invoiceId': 'INV-20251210-001234',
      'storeName': 'Cafe Lalana',
      'storeAddress': 'Jl. Raya Dago No. 123, Bandung',
      'dateTime': '10 Desember 2025, 14:30 WIB',
      'items': [
        {'name': 'Kopi Latte', 'qty': 2, 'price': 25000},
        {'name': 'Croissant Cokelat', 'qty': 1, 'price': 18000},
        {'name': 'Jus Jeruk', 'qty': 1, 'price': 22000},
        {'name': 'Es Teh Manis', 'qty': 1, 'price': 15000},
      ],
      'taxRate': 0.10,
      'serviceRate': 0.05,
      'paymentMethod': 'QRIS',
      'tableNo': 'Meja 07',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Lainnya')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            subtitle: const Text('Data pengguna & preferensi'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            subtitle: const Text('Tema, bahasa, notifikasi'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(height: 0),

          // ===== Tambahan: Lacak Pesanan =====
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Lacak Pesanan'),
            subtitle: const Text('Status & progress pesanan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderTrackingPage(order: sampleOrder),
                ),
              );
            },
          ),
          const Divider(height: 0),

          // ===== Tambahan: Struk Digital =====
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Struk Digital'),
            subtitle: const Text('Ringkasan pembayaran & total'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DigitalReceiptPage(receipt: sampleReceipt),
                ),
              );
            },
          ),
          const Divider(height: 0),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar Akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
