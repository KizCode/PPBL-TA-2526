import 'package:flutter/material.dart';
import '../../services/mock_api.dart';
import '../product/models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/network_image_widget.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = '/';
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MockApi api = MockApi();
  List<Product> _items = [];
  String _filter = 'All';
  bool _reorderMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAsync();
  }

  Future<void> _loadAsync() async {
    final list = await api.fetchMenu();
    if (!mounted) return;
    
    setState(() {
      _items = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{'All'}..addAll(_items.map((e) => e.category));
    final filtered = _filter == 'All' ? _items : _items.where((e) => e.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Menu'), actions: [
        IconButton(
          tooltip: _reorderMode ? 'Done reordering' : 'Reorder items',
          icon: Icon(_reorderMode ? Icons.check : Icons.drag_handle),
          onPressed: () => setState(() => _reorderMode = !_reorderMode),
        ),
        IconButton(onPressed: () => Navigator.pushNamed(context, '/cart'), icon: Icon(Icons.shopping_cart))
      ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.restaurant, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('CafeSync App', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Menu'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Promo & Voucher'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/promos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Pesanan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/order-history');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Keranjang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cart');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ), 
      body: Column(
        children: [
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ChoiceChip(label: Text(c), selected: _filter == c, onSelected: (_) => setState(() => _filter = c)),
              )).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _reorderMode
              ? ReorderableListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final p = _items[index];
                    return ListTile(
                      key: ValueKey(p.id),
                      leading: SizedBox(width: 64, height: 48, child: NetworkImageWidget(url: p.image, fit: BoxFit.cover)),
                      title: Text(p.name),
                      subtitle: Text('Rp ${p.price}'),
                      trailing: Icon(Icons.drag_handle),
                    );
                  },
                )
              : GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, idx) {
                    final p = filtered[idx];
                    return ProductCard(
                      key: ValueKey(p.id),
                      product: p,
                      onTap: () {
                        // Product detail removed - admin only app
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
