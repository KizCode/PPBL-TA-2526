import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../prefs/cart_prefs.dart';
import '../repositories/cart_repository.dart';
import '../../../home_shell.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final _cartRepo = CartRepository();

  // Dummy menu data (replace with real menu table/API later)
  final List<_DummyMenu> _menus = const [
    _DummyMenu(id: 1, name: 'Nasi Goreng Lalana', price: 25000),
    _DummyMenu(id: 2, name: 'Mie Goreng Spesial', price: 23000),
    _DummyMenu(id: 3, name: 'Ayam Geprek', price: 22000),
    _DummyMenu(id: 4, name: 'Es Teh Manis', price: 8000),
    _DummyMenu(id: 5, name: 'Kopi Susu Lalana', price: 15000),
  ];

  bool _adding = false;

  String _formatRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buffer.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  Future<void> _addToCart(_DummyMenu menu) async {
    final userId = await CartPrefs.getActiveUser();
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu.')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      return;
    }

    setState(() => _adding = true);
    try {
      await _cartRepo.addItem(
        CartItemModel(
          userId: userId,
          menuId: menu.id,
          menuName: menu.name,
          quantity: 1,
          price: menu.price,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ditambahkan: ${menu.name}')));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Lalana Kafe'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: () {
              final scope = HomeShellScope.maybeOf(context);
              if (scope != null) {
                scope.setIndex(HomeTabs.cart);
              } else {
                Navigator.pushReplacementNamed(context, '/cart');
              }
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              final scope = HomeShellScope.maybeOf(context);
              if (scope != null) {
                scope.setIndex(HomeTabs.profile);
              } else {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _menus.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final menu = _menus[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(_formatRupiah(menu.price)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _adding ? null : () => _addToCart(menu),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DummyMenu {
  final int id;
  final String name;
  final int price;
  const _DummyMenu({required this.id, required this.name, required this.price});
}
