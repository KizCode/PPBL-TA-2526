import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'product_form_screen.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _repo = ProductRepository();

  Future<List<ProductModel>> _load() => _repo.all();

  Future<void> _openForm({ProductModel? initial}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(initial: initial)),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _delete(ProductModel product) async {
    final id = product.id;
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus produk?'),
          content: Text('Hapus "${product.name}" beserta resepnya?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await _repo.delete(id);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada produk. Tambahkan dulu.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = items[index];
              return ProductCard(
                product: p,
                onEdit: () => _openForm(initial: p),
                onDelete: () => _delete(p),
              );
            },
          );
        },
      ),
    );
  }
}
