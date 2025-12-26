import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as models;
import '../../../widgets/admin_drawer.dart';

class CategoryAdminScreen extends StatelessWidget {
  static const routeName = '/admin/categories';
  const CategoryAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: CategoryAdminScreen.routeName),
      body: provider.categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Belum ada kategori', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kategori'),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.categories.length,
              onReorder: (oldIndex, newIndex) {
                // Reordering logic bisa ditambahkan di sini
              },
              itemBuilder: (context, idx) {
                final cat = provider.categories[idx];
                return Card(
                  key: ValueKey(cat.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.isActive ? Colors.purple : Colors.grey,
                      child: Text(
                        cat.icon.isNotEmpty ? cat.icon : '📁',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.description),
                        Text('Urutan: ${cat.sortOrder}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: cat.isActive,
                          onChanged: (val) {
                            final updated = models.Category(
                              id: cat.id,
                              name: cat.name,
                              description: cat.description,
                              icon: cat.icon,
                              sortOrder: cat.sortOrder,
                              isActive: val,
                            );
                            provider.updateCategory(updated);
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showAddEditDialog(context, cat);
                            } else if (val == 'delete') {
                              _confirmDelete(context, cat);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, null),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, models.Category? cat) {
    final isEdit = cat != null;
    final nameCtrl = TextEditingController(text: cat?.name);
    final descCtrl = TextEditingController(text: cat?.description);
    final iconCtrl = TextEditingController(text: cat?.icon);
    final sortCtrl = TextEditingController(text: cat?.sortOrder.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Kategori')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
              TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Icon/Emoji (opsional)')),
              TextField(controller: sortCtrl, decoration: const InputDecoration(labelText: 'Urutan Tampil'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final newCat = models.Category(
                id: cat?.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                icon: iconCtrl.text.trim().isNotEmpty ? iconCtrl.text.trim() : '📁',
                sortOrder: int.tryParse(sortCtrl.text) ?? 0,
                isActive: cat?.isActive ?? true,
              );
              
              if (isEdit) {
                Provider.of<CategoryProvider>(context, listen: false).updateCategory(newCat);
              } else {
                Provider.of<CategoryProvider>(context, listen: false).addCategory(newCat);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, models.Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Hapus kategori "${cat.name}"?\n\nPerhatian: Menu dengan kategori ini akan tetap ada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false).deleteCategory(cat.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
