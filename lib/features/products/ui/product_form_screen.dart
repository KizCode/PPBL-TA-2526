import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  final _imagePicker = ImagePicker();

  final _materialRepo = MaterialRepository();
  final _productRepo = ProductRepository();

  bool _saving = false;
  List<MaterialModel> _materials = const [];
  List<RecipeLine> _recipeLines = const [];
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _existingImageUrl = p.imageUrl;
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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<String?> _saveImageToLocal(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/product_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${imagesDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      return null;
    }
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

    // Save image if new image selected
    String? imageUrl = _existingImageUrl;
    if (_imageFile != null) {
      imageUrl = await _saveImageToLocal(_imageFile!);
    }

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
          imageUrl: imageUrl,
          recipeItems: recipeItems,
        );
      } else {
        await _productRepo.updateWithRecipe(
          product: widget.initial!.copyWith(
            name: name,
            price: price,
            imageUrl: imageUrl,
          ),
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
                        const SizedBox(height: 12),
                        
                        // Image Picker Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gambar Produk',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).cardColor,
                                ),
                                child: _imageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : _existingImageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              File(_existingImageUrl!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                                            ),
                                          )
                                        : _buildImagePlaceholder(),
                              ),
                            ),
                            if (_imageFile != null || _existingImageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _imageFile = null;
                                      _existingImageUrl = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Hapus Gambar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Stok akan dihitung otomatis berdasarkan bahan yang tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
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

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap untuk pilih gambar',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
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
