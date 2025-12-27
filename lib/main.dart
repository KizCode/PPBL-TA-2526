// ============================================================================
// MAIN.DART - Entry Point Aplikasi CafeSync Admin
// ============================================================================
// File ini adalah titik masuk (entry point) aplikasi. Semua dimulai dari sini.
// Fungsi utama: Setup Provider (state management) dan routing (navigasi antar halaman)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

// Import Provider - untuk mengelola state/data aplikasi
import 'features/ingredient/providers/ingredient_provider.dart';      // Kelola data stok bahan
import 'features/category/providers/category_provider.dart';          // Kelola data kategori menu
import 'features/product/providers/product_admin_provider.dart';      // Kelola data produk/menu

// Import Screens - semua halaman aplikasi
import 'features/menu/menu_screen.dart';
import 'features/dashboard/screens/admin_dashboard.dart';
import 'features/product/screens/admin_product_screen.dart';
import 'features/ingredient/screens/admin_ingredient_screen.dart';
import 'features/category/screens/admin_category_screen.dart';

// ============================================================================
// FUNGSI MAIN - Titik Awal Aplikasi
// ============================================================================
// Ini adalah fungsi pertama yang dijalankan saat aplikasi dibuka
// Setup database factory untuk web, lalu runApp()
void main() {
  // Setup database untuk web browser
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  runApp(const MyApp());
}

// ============================================================================
// CLASS MyApp - Root Widget Aplikasi
// ============================================================================
// StatelessWidget = Widget yang tidak berubah (immutable)
// Widget ini adalah parent/induk dari semua widget lainnya
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // MULTIPROVIDER - State Management Global
    // ========================================================================
    // MultiProvider membungkus seluruh aplikasi sehingga semua widget bisa
    // mengakses data dari provider tanpa harus passing data manual
    // 
    // Cara kerja:
    // 1. Provider menyimpan data (List products, ingredients, dll)
    // 2. Saat data berubah, provider.notifyListeners() dipanggil
    // 3. Semua widget yang "listening" akan auto rebuild dengan data baru
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider = Provider yang bisa notify perubahan data
        // create: (_) => ... : Membuat instance provider sekali saat app start
        
        ChangeNotifierProvider(create: (_) => IngredientProvider()),
        // ↑ Provider untuk kelola stok bahan (tambah, edit, hapus, cek low stock)
        
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        // ↑ Provider untuk kelola kategori menu (Coffee, Snack, Dessert, dll)
        
        ChangeNotifierProvider(create: (_) => ProductAdminProvider()),
        // ↑ Provider untuk kelola menu/produk (CRUD produk cafe)
      ],
      
      // ======================================================================
      // MATERIALAPP - Konfigurasi Aplikasi
      // ======================================================================
      child: MaterialApp(
        title: 'CafeSync Admin',  // Nama aplikasi (muncul di task manager)
        
        // Theme = Tema visual aplikasi (warna, font, dll)
        theme: ThemeData(primarySwatch: Colors.green),  // Tema hijau
        
        // initialRoute = Halaman pertama yang dibuka saat app start
        initialRoute: AdminDashboard.routeName,  // '/admin' (dashboard)
        
        // ====================================================================
        // ROUTES - Mapping Nama Route ke Widget Screen
        // ====================================================================
        // Route = Alamat/path halaman, seperti URL di web
        // Format: 'nama_route': (context) => WidgetScreen()
        // 
        // Cara navigasi:
        // Navigator.pushNamed(context, '/admin/products') → buka halaman menu
        routes: {
          AdminDashboard.routeName: (_) => const AdminDashboard(),
          // '/admin' → Halaman Dashboard (overview stats)
          
          ProductAdminScreen.routeName: (_) => const ProductAdminScreen(),
          // '/admin/products' → Halaman CRUD Menu/Produk
          
          IngredientAdminScreen.routeName: (_) => const IngredientAdminScreen(),
          // '/admin/ingredients' → Halaman CRUD & Monitor Stok Bahan
          
          CategoryAdminScreen.routeName: (_) => const CategoryAdminScreen(),
          // '/admin/categories' → Halaman CRUD Kategori Menu
          
          MenuScreen.routeName: (_) => MenuScreen(),
          // '/' → Halaman Preview Menu (opsional)
        },
      ),
    );
  }
}

// ============================================================================
// KONSEP PENTING:
// ============================================================================
// 1. PROVIDER PATTERN (State Management)
//    - Data disimpan di Provider (single source of truth)
//    - Semua screen bisa akses & update data via Provider
//    - Auto sync: Update di 1 tempat → semua screen ikut update
//
// 2. ROUTING (Navigasi)
//    - Named Routes: Pakai nama string ('/admin') bukan widget langsung
//    - Keuntungan: Mudah navigate, clear navigation flow
//    - Navigator.pushNamed() = pindah halaman
//    - Navigator.pop() = kembali
//
// 3. WIDGET TREE
//    MyApp
//    └─ MultiProvider (state management wrapper)
//       └─ MaterialApp (app configuration)
//          └─ Scaffold (page structure)
//             ├─ AppBar
//             ├─ Drawer (navigation menu)
//             └─ Body (konten utama)
// ============================================================================
