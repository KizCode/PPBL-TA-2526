import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as models;
import '../../../widgets/admin_drawer.dart';

class CategoryAdminScreen extends StatelessWidget {
  static const routeName = '/admin/categories';
  const CategoryAdminScreen({super.key});

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
                  Text(
                    'Belum ada kategori',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
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
              onReorder: (oldIndex, newIndex) async {
                // Penyesuaian index jika drag ke bawah
                if (newIndex > oldIndex) newIndex -= 1;
                final provider = Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                );
                final cat = provider.categories.removeAt(oldIndex);
                provider.categories.insert(newIndex, cat);
                // Update sortOrder sesuai urutan baru
                for (int i = 0; i < provider.categories.length; i++) {
                  final c = provider.categories[i];
                  if (c.sortOrder != i) {
                    final updated = models.Category(
                      id: c.id,
                      name: c.name,
                      description: c.description,
                      icon: c.icon,
                      sortOrder: i,
                      isActive: c.isActive,
                    );
                    provider.categories[i] = updated;
                    await provider.updateCategory(updated);
                  }
                }
                provider.notifyListeners();
              },
              itemBuilder: (context, idx) {
                final cat = provider.categories[idx];
                return Card(
                  key: ValueKey(cat.id),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    splashColor: Colors.green.withOpacity(0.1),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: cat.isActive
                              ? const LinearGradient(
                                          colors: [
                                            Color(0xFF8BC34A),
                                            Color(0xFF4CAF50),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 56, 56),
                                        ) !=
                                        null
                                    ? Colors.green[400]
                                    : Colors.purple
                              : Colors.grey[400],
                          child: Text(
                            cat.icon.isNotEmpty ? cat.icon : '📁',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        title: Text(
                          cat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.2,
                          ),
                        ),
                        subtitle: cat.description.trim().isNotEmpty
                            ? Builder(
                                builder: (context) => Text(
                                  cat.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: cat.isActive,
                              activeColor: Colors.green[600],
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
                              icon: const Icon(Icons.more_vert),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showAddEditDialog(context, cat);
                                } else if (val == 'delete') {
                                  _confirmDelete(context, cat);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
    final sortCtrl = TextEditingController(
      text: cat?.sortOrder.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
              TextField(
                controller: iconCtrl,
                decoration: const InputDecoration(
                  labelText: 'Icon/Emoji (opsional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<CategoryProvider>(
                context,
                listen: false,
              );
              final newCat = models.Category(
                id: cat?.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                icon: iconCtrl.text.trim().isNotEmpty
                    ? iconCtrl.text.trim()
                    : '📁',
                sortOrder: isEdit
                    ? (cat?.sortOrder ?? 0)
                    : provider.categories.length,
                isActive: cat?.isActive ?? true,
              );

              if (isEdit) {
                Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                ).updateCategory(newCat);
              } else {
                Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                ).addCategory(newCat);
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
        content: Text(
          'Hapus kategori "${cat.name}"?\n\nPerhatian: Menu dengan kategori ini akan tetap ada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CategoryProvider>(
                context,
                listen: false,
              ).deleteCategory(cat.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
