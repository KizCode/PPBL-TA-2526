
import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  /// Struktur order:
  /// {
  ///   'id': String,
  ///   'status': String,           // 'menunggu', 'diproses', 'siap', 'selesai'
  ///   'estimate': String,         // contoh: '15 - 20 menit'
  ///   'items': List<Map>{'name': String, 'qty': int}
  /// }
  final Map<String, dynamic> order;
  const OrderTrackingPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = (order['status']?.toString() ?? 'menunggu').toLowerCase();

    final steps = [
      _StepData(
        key: 'menunggu',
        title: 'Menunggu Konfirmasi',
        desc: 'Pesanan Anda telah diterima.',
      ),
      _StepData(
        key: 'diproses',
        title: 'Sedang Diproses',
        desc: 'Pesanan sedang disiapkan.',
      ),
      _StepData(
        key: 'siap',
        title: 'Siap Diantar',
        desc: 'Pesanan siap untuk diambil atau diantar.',
      ),
      _StepData(
        key: 'selesai',
        title: 'Selesai',
        desc: 'Pesanan Anda telah selesai.',
      ),
    ];

    final currentIndex = steps.indexWhere((s) => s.key == status).clamp(0, steps.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu status utama
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header status + pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Pesanan Anda',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      _StatusPill(statusText: _statusLabel(status)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ID pesanan
                  _infoRow('ID Pesanan', order['id']?.toString() ?? '-'),
                  const SizedBox(height: 6),
                  // Estimasi waktu
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 6),
                      Text('Estimasi: ${order['estimate']?.toString() ?? '-'}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  const Text('Item Pesanan',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ..._buildItemList(order['items'] as List? ?? []),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timeline langkah
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            final done = i <= currentIndex;
            return _StepTile(
              title: s.title,
              desc: s.desc,
              done: done,
              isCurrent: i == currentIndex,
            );
          }),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  static List<Widget> _buildItemList(List items) {
    return items.map((it) {
      final name = it['name']?.toString() ?? 'Item';
      final qty = (it['qty'] as int?) ?? 1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text('x$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }).toList();
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'menunggu': return 'Menunggu';
      case 'diproses': return 'Sedang Diproses';
      case 'siap':     return 'Siap Diantar';
      case 'selesai':  return 'Selesai';
      default:         return 'Menunggu';
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String statusText;
  const _StatusPill({required this.statusText});

  @override
  Widget build(BuildContext context) {
    final color = switch (statusText) {
      'Menunggu' => Colors.orange,
      'Sedang Diproses' => Colors.blue,
      'Siap Diantar' => Colors.purple,
      'Selesai' => Colors.green,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(statusText, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StepData {
  final String key;
  final String title;
  final String desc;
  _StepData({required this.key, required this.title, required this.desc});
}

class _StepTile extends StatelessWidget {
  final String title;
  final String desc;
  final bool done;
  final bool isCurrent;
  const _StepTile({
    required this.title,
    required this.desc,
    required this.done,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = done ? const Color(0xFF22C55E) : Colors.grey.shade400;
    final titleStyle = TextStyle(
      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
