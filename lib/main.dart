// ============================================================================
// MAIN.DART - Entry Point Aplikasi CafeSync Admin
// ============================================================================
// File ini adalah titik masuk (entry point) aplikasi. Semua dimulai dari sini.
// Fungsi utama: Setup Provider (state management) dan routing (navigasi antar halaman)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

// Import Provider - untuk mengelola state/data aplikasi
import 'features/ingredient/providers/ingredient_provider.dart'; // Kelola data stok bahan
import 'features/category/providers/category_provider.dart'; // Kelola data kategori menu
import 'features/product/providers/product_admin_provider.dart'; // Kelola data produk/menu

// Import Screens - semua halaman aplikasi
import 'features/menu/menu_screen.dart';
import 'features/dashboard/screens/settings_screen.dart';
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
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _updateThemeMode(ThemeMode? mode) async {
    setState(() {
      _themeMode = mode ?? ThemeMode.system;
    });
    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await prefs.setString('theme_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IngredientProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductAdminProvider()),
      ],
      child: MaterialApp(
        title: 'CafeSync Admin',
        theme: ThemeData(primarySwatch: Colors.green),
        darkTheme: ThemeData.dark(),
        themeMode: _themeMode,
        initialRoute: AdminDashboard.routeName,
        routes: {
          AdminDashboard.routeName: (_) => const AdminDashboard(),
          ProductAdminScreen.routeName: (_) => const ProductAdminScreen(),
          IngredientAdminScreen.routeName: (_) => const IngredientAdminScreen(),
          CategoryAdminScreen.routeName: (_) => const CategoryAdminScreen(),
          MenuScreen.routeName: (_) => MenuScreen(),
          '/admin/settings': (_) => SettingsScreen(
            onThemeChanged: _updateThemeMode,
            currentThemeMode: _themeMode,
          ),
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
