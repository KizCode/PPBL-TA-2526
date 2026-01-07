import 'package:flutter/material.dart';

import '../models/material_model.dart';
import '../repositories/material_repository.dart';

class MaterialFormScreen extends StatefulWidget {
  final MaterialModel? initial;
  const MaterialFormScreen({super.key, this.initial});

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();

  final _repo = MaterialRepository();

  String _unit = 'pcs';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    if (m != null) {
      _nameController.text = m.name;
      _stockController.text = m.stock.toString();
      _unit = m.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final stock = double.tryParse(_stockController.text.replaceAll(',', '.')) ?? 0;

      if (widget.initial == null) {
        await _repo.create(name: name, unit: _unit, stock: stock);
      } else {
        final updated = widget.initial!.copyWith(
          name: name,
          unit: _unit,
          stock: stock,
        );
        await _repo.update(updated);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Bahan' : 'Tambah Bahan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama bahan'),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Nama wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _unit,
                  items: const [
                    DropdownMenuItem(value: 'gr', child: Text('gr')),
                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                    DropdownMenuItem(value: 'pcs', child: Text('pcs')),
                  ],
                  onChanged: _saving ? null : (v) => setState(() => _unit = v ?? 'pcs'),
                  decoration: const InputDecoration(labelText: 'Satuan'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Stok'),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Stok wajib diisi';
                    final parsed = double.tryParse(s.replaceAll(',', '.'));
                    if (parsed == null) return 'Stok harus angka';
                    if (parsed < 0) return 'Stok tidak boleh negatif';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
