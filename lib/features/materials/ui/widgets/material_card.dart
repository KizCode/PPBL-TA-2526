import 'package:flutter/material.dart';

import '../../models/material_model.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MaterialCard({
    super.key,
    required this.material,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('Stok: ${material.stock.toStringAsFixed(2)} ${material.unit}'),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Hapus',
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
