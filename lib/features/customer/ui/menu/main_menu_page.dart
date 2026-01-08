import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'menu_detail_page.dart';
import '../order/cart_state.dart';
import '../../widgets/menu_card.dart';
import '../../providers/menu_provider.dart';
import '../../models/menu_item.dart';
import '../../../products/services/stock_service.dart';

class MainMenuPage extends StatefulWidget {
  /// Set true hanya jika halaman ini TIDAK berada di HomeShell (standalone).
  /// Kalau kamu sudah pakai HomeShell dengan bottom nav, set ke false (default).
  final bool showLocalNav;
  const MainMenuPage({super.key, this.showLocalNav = false});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final TextEditingController searchCtrl = TextEditingController();
  String selectedCategory = 'Semua';
  int bottomIndex = 1; // kalau showLocalNav=true, default tab Menu

  final categories = const ['Semua', 'Kopi', 'Minuman Non-Kopi', 'Makanan'];

  @override
  void initState() {
    super.initState();
    // Load menu items saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuItems();
    });
  }

  List<MenuItem> get filteredItems {
    final menuProvider = context.watch<MenuProvider>();
    final q = searchCtrl.text.trim().toLowerCase();
    return menuProvider.getMenuItemsByCategory(selectedCategory).where((m) {
      final byText = q.isEmpty || m.name.toLowerCase().contains(q);
      return byText;
    }).toList();
  }

  String rupiah(num v) => 'Rp ${v.toStringAsFixed(0)}';

  Future<void> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true) {
      await SystemNavigator.pop();
    }
  }

  /// BACK ICON yang sesuai konteks:
  /// - Jika ada halaman sebelumnya -> pop
  /// - Jika tidak (mis. ini halaman root) -> arahkan ke HomeShell tab Beranda
  Future<void> _handleBack() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Jika aplikasi pakai HomeShell, pindah ke Beranda
      try {
        // Jika route /home ada, pindah ke tab 0 (Beranda)
        Navigator.pushReplacementNamed(context, '/home', arguments: {'tab': 0});
      } catch (_) {
        // Kalau tidak ada HomeShell, tanya exit
        await _confirmExit();
      }
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);

    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _handleBack,
            tooltip: 'Kembali',
          ),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6)),
                child:
                    const Icon(Icons.local_cafe, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text('Cafeesync',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Keranjang',
              icon: const Icon(Icons.receipt_long),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ],
        ),

        body: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari menu favoritmu ...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Tabs kategori (sesuai preferensi kamu)
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = cat == selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: green.withOpacity(0.15),
                    labelStyle: TextStyle(
                        color: selected 
                          ? green 
                          : Theme.of(context).textTheme.bodyMedium?.color),
                    onSelected: (_) => setState(() => selectedCategory = cat),
                    side: BorderSide(
                        color: selected ? green : Colors.grey.shade300),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // List menu
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredItems.length,
                itemBuilder: (_, i) {
                  final m = filteredItems[i];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MenuDetailPage(item: m.toJson())),
                      );
                    },
                    child: MenuCard(
                      name: m.name,
                      priceText: rupiah(m.price),
                      stock: m.stock,
                      imageUrl: m.imageUrl,
                      onAdd: () async {
                        // Check stock availability
                        final stockService = StockService();
                        final canMake = await stockService.canMakeProduct(m.id, 1);
                        
                        if (!canMake) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${m.name} tidak bisa dibuat karena bahan tidak mencukupi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        await CartState.instance.addItem(
                          id: m.id,
                          name: m.name,
                          price: m.price,
                          quantity: 1,
                        );
                        
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${m.name} ditambahkan ke keranjang')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // >>> PENTING: Bottom nav lokal HANYA tampil jika showLocalNav=true
        bottomNavigationBar: widget.showLocalNav
            ? NavigationBar(
                selectedIndex: bottomIndex,
                onDestinationSelected: (i) {
                  setState(() => bottomIndex = i);
                  switch (i) {
                    case 0:
                      Navigator.pushReplacementNamed(context, '/home',
                          arguments: {'tab': 0}); // Beranda
                      break;
                    case 1:
                      // Menu (stay here)
                      break;
                    case 2:
                      Navigator.pushReplacementNamed(context, '/home',
                          arguments: {'tab': 2}); // Pesanan
                      break;
                    case 3:
                      _showProfileSheet(context);
                      break;
                  }
                },
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Beranda'),
                  NavigationDestination(
                      icon: Icon(Icons.local_cafe_outlined),
                      selectedIcon: Icon(Icons.local_cafe),
                      label: 'Menu'),
                  NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: 'Pesanan'),
                  NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profil'),
                ],
              )
            : null,
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil (dummy)'),
              subtitle: Text('Akan diisi data pengguna nanti'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
