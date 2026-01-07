import 'package:flutter/material.dart';

import '../models/material_model.dart';
import '../repositories/material_repository.dart';
import 'material_form_screen.dart';
import 'widgets/material_card.dart';

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  final _repo = MaterialRepository();

  Future<List<MaterialModel>> _load() => _repo.all();

  Future<void> _openForm({MaterialModel? initial}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MaterialFormScreen(initial: initial)),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _delete(MaterialModel material) async {
    final id = material.id;
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus bahan?'),
          content: Text('Hapus "${material.name}"?'),
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
      body: FutureBuilder<List<MaterialModel>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada bahan. Tambahkan dulu.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = items[index];
              return MaterialCard(
                material: m,
                onEdit: () => _openForm(initial: m),
                onDelete: () => _delete(m),
              );
            },
          );
        },
      ),
    );
  }
}
