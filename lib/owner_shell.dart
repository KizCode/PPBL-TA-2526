import 'package:flutter/material.dart';

import 'features/auth_owner/prefs/owner_auth_prefs.dart';
import 'features/dashboard/ui/owner_dashboard_screen.dart';
import 'features/materials/ui/material_list_screen.dart';
import 'features/products/ui/product_list_screen.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _index = 0;
  bool _checkedAuth = false;

  final _pages = const [
    OwnerDashboardScreen(),
    MaterialListScreen(),
    ProductListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _guardAuth();
  }

  Future<void> _guardAuth() async {
    final loggedIn = await OwnerAuthPrefs.isLoggedIn();
    if (!loggedIn && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/owner-login', (r) => false);
      return;
    }
    if (mounted) setState(() => _checkedAuth = true);
  }

  Future<void> _logout() async {
    await OwnerAuthPrefs.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/owner-login', (r) => false);
  }

  void _go(int idx) {
    if (idx == _index) return;
    setState(() => _index = idx);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(['Dashboard', 'Bahan', 'Produk'][_index]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                title: Text('Owner POS'),
                subtitle: Text('Master data (offline)'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                selected: _index == 0,
                onTap: () => _go(0),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Bahan'),
                selected: _index == 1,
                onTap: () => _go(1),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Produk'),
                selected: _index == 2,
                onTap: () => _go(2),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}
