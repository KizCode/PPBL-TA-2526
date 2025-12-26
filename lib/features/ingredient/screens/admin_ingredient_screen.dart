import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingredient_provider.dart';
import '../models/ingredient.dart';
import '../../../widgets/admin_drawer.dart';

class IngredientAdminScreen extends StatelessWidget {
  static const routeName = '/admin/ingredients';
  const IngredientAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IngredientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Bahan'),
        backgroundColor: Colors.green[700],
        actions: [
          if (provider.lowStockCount > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${provider.lowStockCount} Rendah',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: IngredientAdminScreen.routeName),
      body: provider.ingredients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Belum ada bahan', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Bahan'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.ingredients.length,
              itemBuilder: (context, idx) {
                final ing = provider.ingredients[idx];
                final isLow = ing.isLowStock;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isLow ? Colors.red[50] : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLow ? Colors.red : Colors.green,
                      child: Icon(
                        isLow ? Icons.warning : Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stok: ${ing.quantity} ${ing.unit} ${isLow ? '(Min: ${ing.minStock})' : ''}'),
                        Text('Harga: Rp ${ing.price}/${ing.unit}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => _showStockDialog(context, ing, true),
                          tooltip: 'Tambah Stok',
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.orange),
                          onPressed: () => _showStockDialog(context, ing, false),
                          tooltip: 'Kurangi Stok',
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showAddEditDialog(context, ing);
                            } else if (val == 'delete') {
                              _confirmDelete(context, ing);
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
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Bahan'),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, Ingredient? ing) {
    final isEdit = ing != null;
    final nameCtrl = TextEditingController(text: ing?.name);
    final unitCtrl = TextEditingController(text: ing?.unit);
    final qtyCtrl = TextEditingController(text: ing?.quantity.toString());
    final minStockCtrl = TextEditingController(text: ing?.minStock.toString());
    final priceCtrl = TextEditingController(text: ing?.price.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Bahan' : 'Tambah Bahan Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Bahan')),
              TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Satuan (kg/liter/pcs)')),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Stok Awal'), keyboardType: TextInputType.number),
              TextField(controller: minStockCtrl, decoration: const InputDecoration(labelText: 'Minimum Stok'), keyboardType: TextInputType.number),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga per Satuan'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final newIng = Ingredient(
                id: ing?.id,
                name: nameCtrl.text.trim(),
                unit: unitCtrl.text.trim(),
                quantity: double.tryParse(qtyCtrl.text) ?? 0.0,
                minStock: double.tryParse(minStockCtrl.text) ?? 0.0,
                price: int.tryParse(priceCtrl.text) ?? 0,
                lastUpdated: DateTime.now(),
              );
              
              if (isEdit) {
                Provider.of<IngredientProvider>(context, listen: false).updateIngredient(newIng);
              } else {
                Provider.of<IngredientProvider>(context, listen: false).addIngredient(newIng);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _showStockDialog(BuildContext context, Ingredient ing, bool isAdd) {
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdd ? 'Tambah Stok' : 'Kurangi Stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${ing.name} - Stok saat ini: ${ing.quantity} ${ing.unit}'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(labelText: 'Jumlah (${ing.unit})'),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
              if (qty > 0) {
                if (isAdd) {
                  Provider.of<IngredientProvider>(context, listen: false).addStock(ing.id!, qty);
                } else {
                  Provider.of<IngredientProvider>(context, listen: false).reduceStock(ing.id!, qty);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Ingredient ing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Bahan?'),
        content: Text('Hapus "${ing.name}" dari stok?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Provider.of<IngredientProvider>(context, listen: false).deleteIngredient(ing.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
