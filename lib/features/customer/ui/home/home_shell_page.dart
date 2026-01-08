
import 'package:flutter/material.dart';
import '../menu/main_menu_page.dart';
import '../order/cart_checkout_page.dart';
import 'home_dashboard_tab.dart';
import 'more_tab_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0; // 0: Beranda, 1: Menu, 2: Keranjang, 3: Lainnya

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bisa pindah tab lewat arguments: Navigator.pushNamed('/home', arguments: {'tab': 2});
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['tab'] is int) {
      _index = args['tab'] as int;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeDashboardTab(),     // <-- TANPA showLocalNav
      MainMenuPage(),         // <-- Pastikan tidak ada bottom nav lokal di file ini
      CartCheckoutPage(),
      MoreTabPage(),          // <-- Tab "Lainnya"
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_cafe_outlined),
            selectedIcon: Icon(Icons.local_cafe),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Keranjang',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz), // "Lainnya"
            selectedIcon: Icon(Icons.more),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}
