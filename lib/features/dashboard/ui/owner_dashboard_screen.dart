import 'package:flutter/material.dart';

import '../../materials/repositories/material_repository.dart';
import '../../products/repositories/product_repository.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final materialRepo = MaterialRepository();
    final productRepo = ProductRepository();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FutureBuilder(
          future: Future.wait([
            materialRepo.count(),
            productRepo.count(),
            materialRepo.sumStock(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final values = snapshot.data as List<dynamic>;
            final materialCount = values[0] as int;
            final productCount = values[1] as int;
            final totalStock = values[2] as double;

            return Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Produk',
                    value: productCount.toString(),
                    icon: Icons.restaurant_menu,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Bahan',
                    value: materialCount.toString(),
                    icon: Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Stok',
                    value: totalStock.toStringAsFixed(2),
                    icon: Icons.bar_chart,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Catatan: Pengurangan stok tidak dilakukan otomatis. Stok bahan diubah manual oleh Owner.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
