// ============================================================================
// PRODUCT ADMIN PROVIDER - State Management untuk Data Produk/Menu
// ============================================================================
// Provider = Pengelola data aplikasi (seperti "otak" yang menyimpan memory)
// Fungsi utama:
// 1. Menyimpan list produk di memory (cache)
// 2. Sinkronisasi dengan database
// 3. Memberitahu UI saat data berubah (notifyListeners)
// 4. CRUD operations (Create, Read, Update, Delete)
//
// Pattern: Optimistic Update
// - Update UI dulu (cepat, responsif)
// - Simpan ke database async (background)
// ============================================================================

import 'package:flutter/foundation.dart';  // Untuk ChangeNotifier
import '../models/product.dart';            // Model Product
import '../../../services/db_service.dart';       // Database service

// ============================================================================
// CLASS ProductAdminProvider
// ============================================================================
// 'with ChangeNotifier' = Memberikan kemampuan notifyListeners()
// ChangeNotifier = Class yang bisa memberitahu listener saat ada perubahan
class ProductAdminProvider with ChangeNotifier {
  
  // ==========================================================================
  // PRIVATE PROPERTIES - Data internal (tidak bisa diakses langsung dari luar)
  // ==========================================================================
  final DBService _db = DBService();  // Instance database service
  
  List<Product> _products = [];  // List semua produk (cache di memory)
  // Underscore _ = private (hanya bisa diakses di class ini)
  
  bool _isLoaded = false;  // Flag: sudah load dari database atau belum?
  // Mencegah load berulang kali (efisiensi)

  // ==========================================================================
  // GETTER - Cara mengakses data dari luar class
  // ==========================================================================
  // Getter = Method yang dipanggil seperti property (tanpa ())
  // Contoh: provider.products (bukan provider.products())
  List<Product> get products => _products;
  // Return copy dari _products (readonly dari luar)
  
  // Getter dengan filter: ambil produk berdasarkan kategori
  // Contoh: provider.productsByCategory('Coffee')
  List<Product> productsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
    // where() = filter list (ambil yang cocok kondisi)
    // toList() = convert hasil filter ke List
  }

  // ==========================================================================
  // METHOD: loadProducts() - Load data dari database
  // ==========================================================================
  // async = Operasi asynchronous (tidak block UI)
  // Future<void> = Akan return nilai di masa depan (ketika selesai)
  Future<void> loadProducts() async {
    // Guard: jika sudah pernah load, skip (caching)
    if (_isLoaded) return;
    _isLoaded = true;
    
    // await = Tunggu sampai operasi database selesai
    _products = await _db.getProducts();  // Ambil semua produk dari DB
    
    // notifyListeners() = Beritahu semua widget yang "listen" untuk rebuild
    // Semua widget yang pakai Provider.of<ProductAdminProvider>(context)
    // akan otomatis rebuild dengan data baru
    notifyListeners();
  }

  // ==========================================================================
  // METHOD: addProduct() - Tambah produk baru
  // ==========================================================================
  // Pattern: Optimistic Update
  // 1. Update UI dulu (instant feedback ke user)
  // 2. Simpan ke database async (background)
  Future<void> addProduct(Product prod) async {
    // 1. Tambah ke list (UI langsung update)
    _products.add(prod);
    
    // 2. Sort/urutkan list: berdasarkan kategori, lalu nama
    _products.sort((a, b) {
      final catCmp = a.category.compareTo(b.category);  // Sort kategori
      return catCmp != 0 ? catCmp : a.name.compareTo(b.name);  // Jika sama, sort nama
    });
    
    // 3. Notify UI untuk rebuild dengan data baru
    notifyListeners();
    
    // 4. Simpan ke database (async, tidak block UI)
    await _db.insertProduct(prod);
  }

  // ==========================================================================
  // METHOD: updateProduct() - Edit produk yang sudah ada
  // ==========================================================================
  Future<void> updateProduct(Product prod) async {
    // 1. Cari index produk berdasarkan ID
    final idx = _products.indexWhere((p) => p.id == prod.id);
    // indexWhere() = Cari index pertama yang cocok kondisi
    // Return -1 jika tidak ketemu
    
    // 2. Jika ketemu, update di list
    if (idx >= 0) {
      _products[idx] = prod;  // Replace produk lama dengan yang baru
      notifyListeners();       // Notify UI untuk update
    }
    
    // 3. Update di database
    await _db.updateProduct(prod);
  }

  // ==========================================================================
  // METHOD: deleteProduct() - Hapus produk
  // ==========================================================================
  Future<void> deleteProduct(String id) async {
    // 1. Hapus dari list
    _products.removeWhere((p) => p.id == id);
    // removeWhere() = Hapus semua item yang cocok kondisi
    
    // 2. Notify UI
    notifyListeners();
    
    // 3. Hapus dari database
    await _db.deleteProduct(id);
  }

  // ==========================================================================
  // METHOD: refresh() - Force reload data dari database
  // ==========================================================================
  // Digunakan saat:
  // - User klik tombol refresh
  // - Mau sync data terbaru dari database
  void refresh() {
    _isLoaded = false;     // Reset flag
    loadProducts();        // Load ulang dari database
  }
}

// ============================================================================
// CARA PENGGUNAAN PROVIDER DI WIDGET:
// ============================================================================
//
// 1. AMBIL DATA (Read):
//    final provider = Provider.of<ProductAdminProvider>(context);
//    final products = provider.products;  // Otomatis rebuild saat data berubah
//
// 2. TAMBAH DATA (Create):
//    Provider.of<ProductAdminProvider>(context, listen: false)
//      .addProduct(newProduct);
//    // listen: false = Tidak perlu rebuild, cuma panggil method
//
// 3. UPDATE DATA:
//    Provider.of<ProductAdminProvider>(context, listen: false)
//      .updateProduct(updatedProduct);
//
// 4. DELETE DATA:
//    Provider.of<ProductAdminProvider>(context, listen: false)
//      .deleteProduct(productId);
//
// 5. REFRESH:
//    Provider.of<ProductAdminProvider>(context, listen: false).refresh();
//
// ============================================================================
// KEUNTUNGAN PROVIDER:
// ============================================================================
// ✅ Single Source of Truth - Data terpusat di 1 tempat
// ✅ Auto Sync - Update di 1 screen, semua screen ikut update
// ✅ Separation of Concerns - Logic terpisah dari UI
// ✅ Easy Testing - Bisa test logic tanpa UI
// ✅ Performance - Hanya rebuild widget yang perlu
// ============================================================================
