import 'package:flutter/material.dart';

import '../../materials/models/material_model.dart';
import '../../materials/repositories/material_repository.dart';
import '../models/product_model.dart';
import '../models/recipe_item_model.dart';
import '../repositories/product_repository.dart';
import 'widgets/recipe_input_widget.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? initial;
  const ProductFormScreen({super.key, this.initial});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  final _materialRepo = MaterialRepository();
  final _productRepo = ProductRepository();

  bool _saving = false;
  List<MaterialModel> _materials = const [];
  List<RecipeLine> _recipeLines = const [];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
    }
    _initData();
  }

  Future<void> _initData() async {
    final mats = await _materialRepo.all();

    List<RecipeLine> lines = [];
    final p = widget.initial;
    if (p?.id != null) {
      final recipe = await _productRepo.recipeByProduct(p!.id!);
      lines = recipe
          .map(
            (r) {
              final m = mats.where((x) => x.id == r.materialId).firstOrNull;
              return RecipeLine(
                materialId: r.materialId,
                materialName: m?.name,
                unit: m?.unit,
                qty: r.qty,
              );
            },
          )
          .toList();
    }

    if (!mounted) return;
    setState(() {
      _materials = mats;
      _recipeLines = lines;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan bahan dulu sebelum membuat resep.')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text) ?? 0;

    final recipeItems = _recipeLines
        .where((l) => l.materialId != null && l.qty > 0)
        .map(
          (l) => RecipeItemModel(
            productId: widget.initial?.id ?? 0,
            materialId: l.materialId!,
            qty: l.qty,
          ),
        )
        .toList();

    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        await _productRepo.createWithRecipe(
          name: name,
          price: price,
          recipeItems: recipeItems,
        );
      } else {
        await _productRepo.updateWithRecipe(
          product: widget.initial!.copyWith(name: name, price: price),
          recipeItems: recipeItems,
        );
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
      appBar: AppBar(title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: SafeArea(
        child: _materials.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('Belum ada bahan. Tambahkan bahan dulu.'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Nama produk'),
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) return 'Nama wajib diisi';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Harga jual (Rp)'),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Harga wajib diisi';
                            final parsed = int.tryParse(s);
                            if (parsed == null) return 'Harga harus angka';
                            if (parsed < 0) return 'Harga tidak boleh negatif';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        RecipeInputWidget(
                          materials: _materials,
                          initial: _recipeLines,
                          onChanged: (lines) => _recipeLines = lines,
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
                ],
              ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
