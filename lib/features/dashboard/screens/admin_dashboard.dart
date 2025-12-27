// ============================================================================
// ADMIN DASHBOARD - Halaman utama panel admin
// ============================================================================
// File: admin_dashboard.dart
// Fungsi: Menampilkan ringkasan data dan navigasi cepat ke menu admin lainnya
//
// Fitur:
// - Menampilkan jumlah produk, bahan, kategori dalam card
// - Navigasi cepat ke halaman manajemen (Products, Ingredients, Categories)
// - Badge alert untuk stok bahan yang rendah
// - Grid layout 2 kolom untuk tampilan dashboard
//
// Konsep: Dashboard adalah "home base" admin, dari sini admin bisa lihat
// ringkasan dan langsung jump ke menu yang diinginkan
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ingredient/providers/ingredient_provider.dart';
import '../../product/providers/product_admin_provider.dart';
import '../../category/providers/category_provider.dart';
import '../../../widgets/admin_drawer.dart';

// ============================================================================
// CLASS AdminDashboard - StatefulWidget untuk dashboard dengan data dinamis
// ============================================================================
// Kenapa StatefulWidget?
// - Perlu track loading state (_isLoaded) agar tidak load data berulang
// - State persists selama widget hidup
//
// StatelessWidget vs StatefulWidget:
// - StatelessWidget: Tidak punya state internal (data tetap)
// - StatefulWidget: Punya state internal (data bisa berubah)
// ============================================================================
class AdminDashboard extends StatefulWidget {
  // routeName: Konstanta untuk route ini (dipakai di Navigator)
  static const routeName = '/admin';
  
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

// ============================================================================
// CLASS _AdminDashboardState - State untuk AdminDashboard
// ============================================================================
class _AdminDashboardState extends State<AdminDashboard> {
  // _isLoaded: Flag untuk cek apakah data sudah di-load
  // Kenapa perlu? Agar loadProducts/loadIngredients tidak dipanggil berulang
  // setiap kali widget rebuild
  bool _isLoaded = false;

  // ==========================================================================
  // LIFECYCLE METHOD: didChangeDependencies()
  // ==========================================================================
  // Dipanggil setelah widget terpasang ke widget tree dan bisa akses context
  // 
  // Lifecycle Flutter Widget:
  // 1. Constructor (AdminDashboard())
  // 2. createState() → Buat state
  // 3. initState() → Inisialisasi (TIDAK BISA akses context di sini!)
  // 4. didChangeDependencies() → Bisa akses context (LOAD DATA DI SINI)
  // 5. build() → Render UI
  // 6. dispose() → Cleanup saat widget dihapus
  //
  // Kenapa load data di didChangeDependencies, bukan initState?
  // - Karena perlu akses Provider.of(context) yang butuh BuildContext
  // ==========================================================================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load data hanya sekali saat pertama kali widget dibuat
    if (!_isLoaded) {
      _isLoaded = true;  // Set flag agar tidak load lagi
      
      // Load data dari database via provider
      // listen: false → Tidak subscribe ke perubahan (hanya ambil data)
      Provider.of<IngredientProvider>(context, listen: false).loadIngredients();
      Provider.of<ProductAdminProvider>(context, listen: false).loadProducts();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    }
  }

  // ==========================================================================
  // METHOD build() - Render UI dashboard
  // ==========================================================================
  // Return widget tree yang menampilkan AppBar, Drawer, dan Grid Cards
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // Akses provider untuk baca data (listen: true → auto-rebuild saat data berubah)
    final ingredientProvider = Provider.of<IngredientProvider>(context);
    final productProvider = Provider.of<ProductAdminProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // ========================================================================
    // SCAFFOLD - Struktur dasar halaman (AppBar + Body + Drawer)
    // ========================================================================
    return Scaffold(
      // AppBar: Top bar dengan title dan warna hijau
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green[700],
      ),
      
      // Drawer: Menu navigasi samping (hamburger menu)
      drawer: const AdminDrawer(currentRoute: AdminDashboard.routeName),
      
      // Body: Konten utama halaman
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        
        // ====================================================================
        // GRIDVIEW - Layout grid 2 kolom untuk dashboard cards
        // ====================================================================
        // GridView.count: Grid dengan jumlah kolom tetap
        // Alternatif: GridView.builder (untuk data dinamis panjang)
        child: GridView.count(
          crossAxisCount: 2,        // 2 kolom
          crossAxisSpacing: 16,     // Jarak horizontal antar card
          mainAxisSpacing: 16,      // Jarak vertical antar card
          
          // children: List widget yang ditampilkan di grid
          children: [
            // ================================================================
            // CARD 1: Manajemen Menu (Products)
            // ================================================================
            _buildDashboardCard(
              context,
              icon: Icons.restaurant_menu,
              title: 'Manajemen Menu',
              subtitle: '${productProvider.products.length} item',
              color: Colors.green[600]!,
              onTap: () => Navigator.pushNamed(context, '/admin/products'),
            ),
            
            // ================================================================
            // CARD 2: Stok Bahan (Ingredients) - dengan badge low stock
            // ================================================================
            _buildDashboardCard(
              context,
              icon: Icons.inventory_2,
              title: 'Stok Bahan',
              subtitle: '${ingredientProvider.ingredients.length} bahan',
              // badge: Tampilkan alert jika ada bahan stok rendah
              badge: ingredientProvider.lowStockCount > 0 
                  ? '${ingredientProvider.lowStockCount} Rendah!' 
                  : null,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/admin/ingredients'),
            ),
            
            // ================================================================
            // CARD 3: Kategori
            // ================================================================
            _buildDashboardCard(
              context,
              icon: Icons.category,
              title: 'Kategori',
              subtitle: '${categoryProvider.categories.length} kategori',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/admin/categories'),
            ),
            
            // ================================================================
            // CARD 4: Pengaturan (placeholder, belum ada screen)
            // ================================================================
            _buildDashboardCard(
              context,
              icon: Icons.settings,
              title: 'Pengaturan',
              subtitle: 'Konfigurasi',
              color: Colors.blueGrey,
              onTap: () {
                // SnackBar: Tampilkan notifikasi sementara di bawah layar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur dalam pengembangan')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // METHOD _buildDashboardCard() - Builder untuk card dashboard
  // ==========================================================================
  // Helper method untuk membuat card yang reusable dengan parameter custom
  //
  // Parameter:
  // - context: BuildContext untuk navigasi
  // - icon: Icon yang ditampilkan
  // - title: Judul card
  // - subtitle: Deskripsi/info card
  // - color: Warna icon
  // - onTap: Callback saat card diklik
  // - badge: (optional) Text badge merah untuk alert (misal: stok rendah)
  //
  // Return: Widget Card dengan InkWell (efek ripple saat diklik)
  // ==========================================================================
  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,  // Optional parameter (bisa null)
  }) {
    // ========================================================================
    // CARD - Material Design card dengan shadow
    // ========================================================================
    return Card(
      elevation: 4,  // Tinggi shadow (0 = flat, 24 = sangat tinggi)
      
      // ======================================================================
      // INKWELL - Widget untuk detect tap dengan efek ripple
      // ======================================================================
      // InkWell vs GestureDetector:
      // - InkWell: Ada efek visual ripple saat diklik (Material Design)
      // - GestureDetector: Tidak ada efek visual, hanya detect gesture
      child: InkWell(
        onTap: onTap,  // Callback saat card diklik
        
        // ====================================================================
        // STACK - Overlay widget bertumpuk (badge di atas card content)
        // ====================================================================
        // Stack seperti layer Photoshop: widget ditumpuk dari bawah ke atas
        child: Stack(
          children: [
            // ==================================================================
            // LAYER 1 (Bottom): Card content (icon + title + subtitle)
            // ==================================================================
            Padding(
              padding: const EdgeInsets.all(16.0),
              
              // ================================================================
              // COLUMN - Layout vertical (icon, title, subtitle dari atas ke bawah)
              // ================================================================
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // Center vertical
                children: [
                  // Icon besar dengan warna custom
                  Icon(icon, size: 48, color: color),
                  
                  const SizedBox(height: 12),  // Spasi 12px
                  
                  // Title dengan font bold
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 4),  // Spasi 4px
                  
                  // Subtitle dengan warna abu-abu
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // ==================================================================
            // LAYER 2 (Top): Badge alert (jika ada)
            // ==================================================================
            // if (condition) widget → Conditional widget rendering
            // Tampilkan badge hanya jika badge != null
            if (badge != null)
              // ================================================================
              // POSITIONED - Posisi absolut dalam Stack
              // ================================================================
              // top: 8 → Jarak 8px dari atas
              // right: 8 → Jarak 8px dari kanan
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  
                  // Decoration: Background merah dengan border radius
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  
                  // Text putih kecil bold
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CARA KERJA DASHBOARD:
// ============================================================================
//
// 1. User buka app → Navigate ke /admin (main.dart route)
// 2. AdminDashboard di-build:
//    - didChangeDependencies() → Load data dari DB via Provider
//    - build() → Render UI dengan data dari Provider
//
// 3. Provider.of<ProductAdminProvider>(context) →
//    - listen: true (default) → Widget rebuild otomatis saat data berubah
//    - Contoh: Admin tambah produk → products.length update → Card rebuild
//
// 4. User klik card "Manajemen Menu":
//    - onTap triggered → Navigator.pushNamed('/admin/products')
//    - Navigate ke AdminProductScreen
//
// 5. User kembali ke dashboard (via back button / drawer):
//    - Dashboard masih di memory (tidak di-dispose)
//    - _isLoaded = true → Tidak load data lagi (data sudah ada)
//    - Tapi UI tetap update jika ada perubahan (karena listen: true)
//
// ============================================================================
// KONSEP PENTING:
// ============================================================================
//
// - StatefulWidget: Widget dengan state internal (_isLoaded)
// - Lifecycle: initState → didChangeDependencies → build → dispose
// - Provider: State management untuk sync data antar widget
// - GridView: Layout grid untuk tampilan dashboard
// - Stack: Overlay widget (badge di atas card)
// - InkWell: Detect tap dengan efek ripple
// - Navigator: Navigasi antar halaman
//
// ============================================================================
