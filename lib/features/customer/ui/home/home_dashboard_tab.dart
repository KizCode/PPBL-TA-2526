
import 'package:flutter/material.dart';
import '../../../auth_customer/prefs/auth_prefs.dart';
import '../order/cart_state.dart';

String rupiah(num value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
  }
  return 'Rp ${buf.toString()}';
}

class HomeDashboardTab extends StatefulWidget {
  const HomeDashboardTab({super.key});

  @override
  State<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<HomeDashboardTab> {
  final cart = CartState.instance;
  String _username = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await AuthPrefs.getUsername() ?? 'Pengguna';
    setState(() {
      _username = username.split('@').first; // Ambil bagian sebelum @ jika email
    });
  }

  Future<void> _openCart() async {
    await Navigator.pushNamed(context, '/cart');
    setState(() {}); // refresh badge setelah kembali dari /cart
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            onPressed: _openCart,
            tooltip: 'Keranjang',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.receipt_long),
                if (cart.totalItems > 0)
                  Positioned(
                    right: -4, top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        cart.totalItems.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Selamat datang, $_username 👋',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Cafeesync - D3 Sistem Informasi, FIT',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  )),
          const SizedBox(height: 16),

          _promoBanner(),
          const SizedBox(height: 16),

          _sectionTitle('Kategori'),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryChip(icon: Icons.local_cafe, label: 'Kopi'),
                _CategoryChip(icon: Icons.local_drink, label: 'Teh'),
                _CategoryChip(icon: Icons.cake, label: 'Snack'),
                _CategoryChip(icon: Icons.local_pizza, label: 'Roti'),
                _CategoryChip(icon: Icons.icecream, label: 'Dessert'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionTitle('Akses Cepat'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _shortcutCard(
                  icon: Icons.local_cafe,
                  title: 'Lihat Menu',
                  subtitle: 'Pilihan terbaru',
                  onTap: () => Navigator.pushNamed(context, '/menu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _shortcutCard(
                  icon: Icons.receipt_long,
                  title: 'Pesanan',
                  subtitle: 'Keranjang & Checkout',
                  onTap: _openCart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _sectionTitle('Pesanan Terakhir'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Kopi Susu Gula Aren, 2 item'),
              subtitle: Text('Total: ${rupiah(45000)} • 10 Des 2025'),
              trailing: TextButton(
                onPressed: _openCart,
                child: const Text('Lihat'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pushNamed(context, '/menu'),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Mulai Pesan Sekarang'),
            ),
          )
        ],
      ),
    );
  }

  Widget _promoBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 140,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Promo Akhir Tahun 🎉\nDiskon 20% untuk semua menu.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Positioned(
            right: 0, bottom: 0,
            child: Icon(Icons.local_offer, size: 120, 
                color: Theme.of(context).colorScheme.surfaceContainerHigh),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

  Widget _shortcutCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, color: Theme.of(context).colorScheme.primary),
        label: Text(label),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
