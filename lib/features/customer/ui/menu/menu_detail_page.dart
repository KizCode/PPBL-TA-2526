
import 'package:flutter/material.dart';
import '../order/cart_state.dart';
import '../../../products/services/stock_service.dart';

class MenuDetailPage extends StatefulWidget {
  /// item: { id, name, price, image, description }
  final Map<String, dynamic> item;
  const MenuDetailPage({super.key, required this.item});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  int qty = 1;
  final notesCtrl = TextEditingController();

  String rupiah(num v) => 'Rp ${v.toStringAsFixed(0)}';

  void _dec() => setState(() { if (qty > 1) qty--; });
  void _inc() => setState(() { qty++; });

  void _addToCart() async {
    final id = widget.item['id'] as int;
    final name = widget.item['name']?.toString() ?? 'Menu';
    final price = (widget.item['price'] is num)
        ? (widget.item['price'] as num)
        : num.tryParse(widget.item['price']?.toString() ?? '0') ?? 0;

    // Check stock availability
    final stockService = StockService();
    final canMake = await stockService.canMakeProduct(id, qty);
    
    if (!canMake) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name tidak bisa dibuat karena bahan tidak mencukupi untuk $qty porsi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    CartState.instance.addItem(
      id: id, name: name, price: price, quantity: qty,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name ditambahkan ke keranjang')),
    );

    // Buka halaman Pesanan (Keranjang & Checkout)
    Navigator.pushNamed(context, '/cart');

    // Atau pindah ke shell tab "Pesanan":
    // Navigator.pushReplacementNamed(context, '/home', arguments: {'tab': 2});
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.item['name']?.toString() ?? 'Menu';
    final price = (widget.item['price'] is num)
        ? (widget.item['price'] as num)
        : num.tryParse(widget.item['price']?.toString() ?? '0') ?? 0;
    final imageUrl = widget.item['image']?.toString() ?? '';
    final description =
        widget.item['description']?.toString() ?? 'Tidak ada deskripsi.';
    const green = Color(0xFF22C55E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 180, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180, color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                    Positioned(
                      left: 12, bottom: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(rupiah(price),
                              style: const TextStyle(
                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'Deskripsi',
                child: Text(description),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'Jumlah',
                child: Row(
                  children: [
                    IconButton(onPressed: _dec, icon: const Icon(Icons.remove_circle_outline)),
                    Text('$qty', style: const TextStyle(fontSize: 16)),
                    IconButton(onPressed: _inc, icon: const Icon(Icons.add_circle_outline), color: green),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'Catatan Tambahan',
                child: TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Kurangi gula, tanpa es',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Tambah ke Keranjang', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
