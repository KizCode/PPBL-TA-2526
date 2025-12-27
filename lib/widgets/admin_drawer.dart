// ============================================================================
// ADMIN DRAWER - Navigation Menu Sidebar
// ============================================================================
// Drawer = Menu sidebar yang muncul dari kiri (bisa swipe atau klik icon ☰)
// Widget ini dipakai di semua admin screen untuk navigasi konsisten
//
// Fitur:
// 1. Header dengan gradient & logo
// 2. Menu navigasi ke semua halaman admin
// 3. Highlight menu yang sedang aktif
// 4. Dialog "Tentang" aplikasi
// ============================================================================

import 'package:flutter/material.dart';

// Import semua screen untuk routing
import '../features/dashboard/screens/admin_dashboard.dart';
import '../features/product/screens/admin_product_screen.dart';
import '../features/ingredient/screens/admin_ingredient_screen.dart';
import '../features/category/screens/admin_category_screen.dart';

// ============================================================================
// CLASS AdminDrawer - Reusable Navigation Widget
// ============================================================================
// StatelessWidget = Widget yang tidak berubah setelah dibuat
// Kenapa stateless? Drawer tidak perlu state internal, hanya terima currentRoute
class AdminDrawer extends StatelessWidget {
  // Property: route halaman yang sedang aktif
  // Digunakan untuk highlight menu yang sesuai
  final String currentRoute;

  // Constructor: wajib isi currentRoute saat pakai widget ini
  // Contoh: AdminDrawer(currentRoute: '/admin')
  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // DRAWER WIDGET - Container sidebar menu
    // ========================================================================
    return Drawer(
      // ListView = Scrollable list (jika menu banyak, bisa di-scroll)
      child: ListView(
        padding: EdgeInsets.zero, // Hapus padding default
        children: [
          // ==================================================================
          // DRAWER HEADER - Bagian atas dengan gradient & info app
          // ==================================================================
          DrawerHeader(
            // Dekorasi: gradient hijau untuk visual menarik
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
                begin: Alignment.topLeft, // Mulai dari kiri atas
                end: Alignment.bottomRight, // Ke kanan bawah
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align kiri
              mainAxisAlignment: MainAxisAlignment.end, // Posisi bawah
              children: [
                // Icon admin panel
                const Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8), // Spacing vertikal
                // Judul aplikasi
                const Text(
                  'CafeSync Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Subtitle
                Text(
                  'Manajemen Sistem',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ==================================================================
          // MENU ITEMS - Daftar navigasi
          // ==================================================================

          // Menu Dashboard
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: AdminDashboard.routeName, // '/admin'
          ),

          const Divider(), // Garis pemisah
          // Menu Manajemen Menu/Produk
          _buildMenuItem(
            context,
            icon: Icons.restaurant_menu,
            title: 'Manajemen Menu',
            route: ProductAdminScreen.routeName, // '/admin/products'
          ),

          // Menu Stok Bahan
          _buildMenuItem(
            context,
            icon: Icons.inventory_2,
            title: 'Stok Bahan',
            route: IngredientAdminScreen.routeName, // '/admin/ingredients'
          ),

          // Menu Kategori
          _buildMenuItem(
            context,
            icon: Icons.category,
            title: 'Kategori',
            route: CategoryAdminScreen.routeName, // '/admin/categories'
          ),

          const Divider(), // Garis pemisah
          // ==================================================================
          // MENU TENTANG - Dialog info aplikasi
          // ==================================================================
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text('Tentang'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu

              // Tampilkan dialog info
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('CafeSync Admin v1.0'),
                  content: const Text(
                    'Sistem manajemen cafe untuk CRUD menu, stok bahan, dan kategori.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx), // Tutup dialog
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METHOD _buildMenuItem() - Builder untuk menu item dengan highlight
  // ==========================================================================
  // Helper method untuk membuat menu item yang reusable
  // Kenapa dipisah jadi method? DRY (Don't Repeat Yourself) - code lebih bersih
  //
  // Parameter:
  // - context: BuildContext untuk navigasi
  // - icon: Icon yang ditampilkan di sebelah kiri
  // - title: Text menu
  // - route: Route tujuan saat menu diklik
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = currentRoute == route;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor;
    Color? iconColor;
    Color? selectedTileColor;
    if (isDark) {
      textColor = Colors.white;
      iconColor = Colors.white;
      selectedTileColor = Colors.green[900]?.withOpacity(0.3);
    } else {
      textColor = isActive ? Colors.green[700]! : Colors.black87;
      iconColor = isActive ? Colors.green[700] : Colors.grey[700];
      selectedTileColor = Colors.green[50];
    }
    return ListTile(
      selected: isActive,
      selectedTileColor: selectedTileColor,
      leading: Icon(icon, color: isDark ? iconColor : iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
      trailing: isActive
          ? Icon(
              Icons.arrow_right,
              color: isDark ? Colors.white : Colors.green[700],
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}

// ============================================================================
// CARA PENGGUNAAN WIDGET INI:
// ============================================================================
//
// Di screen mana saja, tambahkan di Scaffold:
//
// Scaffold(
//   appBar: AppBar(title: Text('Halaman Admin')),
//   drawer: AdminDrawer(currentRoute: '/admin'),  // Pass route saat ini
//   body: ...
// )
//
// Otomatis:
// - Icon ☰ (hamburger menu) muncul di AppBar
// - User bisa swipe dari kiri untuk buka drawer
// - Menu yang aktif akan di-highlight hijau
//
// ============================================================================
// NAVIGASI FLOW:
// ============================================================================
//
// User di Dashboard (/admin):
// 1. Buka drawer (klik ☰ atau swipe)
// 2. Klik menu "Manajemen Menu"
// 3. Drawer tutup (Navigator.pop)
// 4. Navigate ke /admin/products (pushReplacementNamed)
// 5. Screen berganti, drawer di screen baru highlight "Manajemen Menu"
//
// ============================================================================
