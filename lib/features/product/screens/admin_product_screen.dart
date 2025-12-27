// ============================================================================
// ADMIN PRODUCT SCREEN - Halaman manajemen produk/menu
// ============================================================================
// File: admin_product_screen.dart
// Fungsi: CRUD (Create, Read, Update, Delete) produk menu kafe
//
// Fitur:
// - Tampilkan list semua produk dengan gambar, nama, harga, kategori
// - Filter produk by kategori (All, Makanan, Minuman, dll)
// - Tambah produk baru via dialog form
// - Edit produk via dialog form
// - Hapus produk dengan konfirmasi
// - Refresh data dari database
//
// UI Components:
// - AppBar dengan tombol refresh
// - ChoiceChip untuk filter kategori (horizontal scroll)
// - ListView produk dengan Card dan PopupMenuButton (Edit/Delete)
// - FloatingActionButton untuk tambah produk
// - Dialog form untuk input data produk
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../providers/product_admin_provider.dart';
import '../../category/providers/category_provider.dart';
import '../models/product.dart';
import '../../../widgets/network_image_widget.dart';
import '../../../widgets/admin_drawer.dart';

// ============================================================================
// CLASS ProductAdminScreen - StatefulWidget untuk manajemen produk
// ============================================================================
// Kenapa StatefulWidget?
// - Perlu track filter state (_filter) yang bisa berubah
// - setState() untuk rebuild UI saat filter berubah
// ============================================================================
class ProductAdminScreen extends StatefulWidget {
  static const routeName = '/admin/products';
  const ProductAdminScreen({super.key});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

// ============================================================================
// CLASS _ProductAdminScreenState - State untuk ProductAdminScreen
// ============================================================================
class _ProductAdminScreenState extends State<ProductAdminScreen> {
  // _filter: Kategori yang sedang dipilih untuk filter ('All' = semua produk)
  String _filter = 'All';
  
  // ImagePicker instance untuk upload gambar
  final ImagePicker _picker = ImagePicker();

  // ==========================================================================
  // METHOD build() - Render UI halaman manajemen produk
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // Akses provider untuk data produk dan kategori
    final productProvider = Provider.of<ProductAdminProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    
    // ========================================================================
    // FILTER LOGIC - Buat set kategori dan filter produk
    // ========================================================================
    // categories: Set berisi 'All' + semua nama kategori
    // Spread operator (...): Expand list jadi individual items
    // Contoh: {'All', 'Makanan', 'Minuman', 'Snack'}
    final categories = {'All', ...categoryProvider.categories.map((c) => c.name)};
    
    // filtered: List produk hasil filter
    // Jika _filter == 'All' → Tampilkan semua produk
    // Jika _filter != 'All' → Filter where category == _filter
    final filtered = _filter == 'All'
        ? productProvider.products
        : productProvider.products.where((p) => p.category == _filter).toList();

    // ========================================================================
    // SCAFFOLD - Struktur halaman
    // ========================================================================
    return Scaffold(
      // ======================================================================
      // APPBAR - Top bar dengan title dan tombol refresh
      // ======================================================================
      appBar: AppBar(
        title: const Text('Manajemen Menu'),
        backgroundColor: Colors.green[700],
        actions: [
          // IconButton: Tombol refresh untuk reload data dari DB
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => productProvider.refresh(),
          ),
        ],
      ),
      
      // Drawer: Menu navigasi samping
      drawer: const AdminDrawer(currentRoute: ProductAdminScreen.routeName),
      
      // ======================================================================
      // BODY - Column layout (Filter chips + ListView produk)
      // ======================================================================
      body: Column(
        children: [
          const SizedBox(height: 8),
          
          // ==================================================================
          // FILTER CHIPS - Horizontal scroll kategori
          // ==================================================================
          // SingleChildScrollView: Scroll horizontal untuk chip kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              // Map categories → ChoiceChip widget
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  
                  // ============================================================
                  // CHOICECHIP - Chip pilihan kategori
                  // ============================================================
                  // ChoiceChip vs FilterChip:
                  // - ChoiceChip: Single selection (radio button style)
                  // - FilterChip: Multi selection (checkbox style)
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _filter == cat,  // Highlight jika kategori aktif
                    
                    // onSelected: Callback saat chip diklik
                    // setState: Update _filter dan rebuild UI
                    onSelected: (_) => setState(() => _filter = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // ==================================================================
          // PRODUCT LIST - ListView produk hasil filter
          // ==================================================================
          // Expanded: Ambil sisa space vertikal yang tersedia
          Expanded(
            child: filtered.isEmpty
                // ==============================================================
                // EMPTY STATE - Tampilan jika belum ada produk
                // ==============================================================
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon besar abu-abu
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        
                        // Text 'Belum ada menu'
                        Text('Belum ada menu', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        
                        // Tombol tambah menu pertama
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(context, null),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Menu'),
                        ),
                      ],
                    ),
                  )
                // ==============================================================
                // PRODUCT LIST - ListView.builder untuk tampilan list produk
                // ==============================================================
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,  // Jumlah item = jumlah produk hasil filter
                    
                    // itemBuilder: Function untuk build setiap item
                    itemBuilder: (context, idx) {
                      final product = filtered[idx];  // Ambil produk by index
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        
                        // ==================================================
                        // LISTTILE - Item produk dengan leading, title, subtitle, trailing
                        // ==================================================
                        child: ListTile(
                          // ================================================
                          // LEADING - Gambar produk (kiri)
                          // ================================================
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: NetworkImageWidget(
                              url: product.image, 
                              fit: BoxFit.cover  // Cover penuh tanpa distorsi
                            ),
                          ),
                          
                          // ================================================
                          // TITLE - Nama produk (bold)
                          // ================================================
                          title: Text(
                            product.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          
                          // ================================================
                          // SUBTITLE - Harga dan kategori
                          // ================================================
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rp ${product.price}'),
                              Text(product.category, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          
                          // ================================================
                          // TRAILING - PopupMenu untuk Edit/Delete (kanan)
                          // ================================================
                          // ================================================
                          // TRAILING - PopupMenu untuk Edit/Delete (kanan)
                          // ================================================
                          trailing: PopupMenuButton<String>(
                            // onSelected: Callback saat menu item dipilih
                            onSelected: (val) {
                              if (val == 'edit') {
                                // Buka dialog edit dengan data produk
                                _showAddEditDialog(context, product);
                              } else if (val == 'delete') {
                                // Buka dialog konfirmasi hapus
                                _confirmDelete(context, product);
                              }
                            },
                            
                            // itemBuilder: Build menu items (Edit, Hapus)
                            itemBuilder: (ctx) => [
                              // Menu item "Edit" dengan icon
                              const PopupMenuItem(
                                value: 'edit', 
                                child: Row(children: [
                                  Icon(Icons.edit, size: 18), 
                                  SizedBox(width: 8), 
                                  Text('Edit')
                                ])
                              ),
                              
                              // Menu item "Hapus" dengan icon merah
                              const PopupMenuItem(
                                value: 'delete', 
                                child: Row(children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red), 
                                  SizedBox(width: 8), 
                                  Text('Hapus', style: TextStyle(color: Colors.red))
                                ])
                              ),
                            ],
                          ),
                          
                          // isThreeLine: true → Beri space lebih untuk subtitle
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // ======================================================================
      // FLOATING ACTION BUTTON - Tombol tambah produk (kanan bawah)
      // ======================================================================
      // FloatingActionButton.extended: FAB dengan icon + label
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, null),  // null = mode tambah
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Menu'),
      ),
    );
  }

  // ==========================================================================
  // METHOD _showAddEditDialog() - Tampilkan dialog form tambah/edit produk
  // ==========================================================================
  // Parameter:
  // - context: BuildContext untuk dialog
  // - product: Product yang akan diedit (null jika mode tambah)
  //
  // Konsep:
  // - Mode tambah: product == null → Form kosong
  // - Mode edit: product != null → Form terisi data produk
  //
  // Form fields:
  // - Nama Menu (TextField)
  // - Deskripsi (TextField multiline)
  // - Harga (TextField number keyboard)
  // - URL Gambar (TextField)
  // - Kategori (DropdownButton)
  // ==========================================================================
  void _showAddEditDialog(BuildContext context, Product? product) {
    // Akses CategoryProvider untuk dropdown kategori
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    // isEdit: true jika product != null (mode edit)
    final isEdit = product != null;
    
    // ========================================================================
    // TEXT CONTROLLERS - Controller untuk input field
    // ========================================================================
    // TextEditingController: Mengontrol dan membaca value dari TextField
    // text: Initial value (terisi jika edit, kosong jika tambah)
    final nameCtrl = TextEditingController(text: product?.name);
    final descCtrl = TextEditingController(text: product?.description);
    final priceCtrl = TextEditingController(text: product?.price.toString());
    
    // Image state: Base64 string untuk gambar (support web & mobile)
    String? selectedImageBase64 = product?.image;
    
    // selectedCategory: Kategori yang dipilih di dropdown
    // Default: Kategori produk (jika edit) atau kategori aktif pertama
    String selectedCategory = product?.category ?? 
      (categoryProvider.activeCategories.isNotEmpty 
        ? categoryProvider.activeCategories.first.name 
        : 'Umum');

    // ========================================================================
    // SHOW DIALOG - Tampilkan dialog modal
    // ========================================================================
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // Title: "Edit Menu" atau "Tambah Menu Baru"
        title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru'),
        
        // ====================================================================
        // DIALOG CONTENT - Form input produk
        // ====================================================================
        // SingleChildScrollView: Scroll jika form panjang (keyboard muncul)
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,  // Tinggi minimal sesuai konten
            children: [
              // ==============================================================
              // INPUT FIELD - Nama Menu
              // ==============================================================
              TextField(
                controller: nameCtrl, 
                decoration: const InputDecoration(labelText: 'Nama Menu')
              ),
              
              // ==============================================================
              // INPUT FIELD - Deskripsi (multiline)
              // ==============================================================
              TextField(
                controller: descCtrl, 
                decoration: const InputDecoration(labelText: 'Deskripsi'), 
                maxLines: 2  // 2 baris text area
              ),
              
              // ==============================================================
              // INPUT FIELD - Harga (numeric keyboard)
              // ==============================================================
              TextField(
                controller: priceCtrl, 
                decoration: const InputDecoration(labelText: 'Harga'), 
                keyboardType: TextInputType.number  // Keyboard angka
              ),
              
              // ==============================================================
              // IMAGE PICKER - Upload gambar dari galeri/kamera
              // ==============================================================
              const SizedBox(height: 12),
              
              StatefulBuilder(
                builder: (ctx, setImageState) => Column(
                  children: [
                    // Preview gambar jika sudah dipilih
                    if (selectedImageBase64 != null && selectedImageBase64!.isNotEmpty)
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: selectedImageBase64!.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(selectedImageBase64!.split(',')[1]),
                                fit: BoxFit.cover,
                              )
                            : Image.network(selectedImageBase64!, fit: BoxFit.cover),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Tombol pilih gambar
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              // Pick image dari galeri
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 85,
                              );
                              
                              if (image != null) {
                                // Convert ke base64 untuk support web & mobile
                                final bytes = await image.readAsBytes();
                                final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                setImageState(() {
                                  selectedImageBase64 = base64String;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galeri'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              // Pick image dari kamera
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.camera,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 85,
                              );
                              
                              if (image != null) {
                                // Convert ke base64
                                final bytes = await image.readAsBytes();
                                final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                setImageState(() {
                                  selectedImageBase64 = base64String;
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Kamera'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ==============================================================
              // DROPDOWN - Pilih Kategori
              // ==============================================================
              // StatefulBuilder: Mini-state untuk update dropdown tanpa rebuild seluruh dialog
              StatefulBuilder(
                builder: (ctx, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  
                  // items: List kategori aktif dari CategoryProvider
                  items: categoryProvider.activeCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.name, 
                      child: Text(cat.name)
                    );
                  }).toList(),
                  
                  // onChanged: Update selectedCategory saat kategori dipilih
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
              ),
            ],
          ),
        ),
        
        // ====================================================================
        // DIALOG ACTIONS - Tombol Batal dan Simpan
        // ====================================================================
        actions: [
          // Tombol "Batal" → Tutup dialog
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Batal')
          ),
          
          // Tombol "Simpan" atau "Update"
          ElevatedButton(
            onPressed: () {
              // ============================================================
              // SAVE LOGIC - Buat object Product baru dari input
              // ============================================================
              final newProduct = Product(
                // id: Pakai id lama (jika edit) atau generate baru (timestamp)
                id: product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                
                name: nameCtrl.text.trim(),  // trim() → Buang spasi di awal/akhir
                description: descCtrl.text.trim(),
                
                // int.tryParse: Konversi string → int (return null jika gagal)
                // ?? 0: Jika null, default ke 0
                price: int.tryParse(priceCtrl.text) ?? 0,
                
                // image: Base64 string dari image picker
                image: selectedImageBase64 ?? '',
                category: selectedCategory,
              );
              
              // ============================================================
              // CALL PROVIDER - Simpan ke database
              // ============================================================
              if (isEdit) {
                // Mode edit → Update produk
                Provider.of<ProductAdminProvider>(context, listen: false)
                  .updateProduct(newProduct);
              } else {
                // Mode tambah → Tambah produk baru
                Provider.of<ProductAdminProvider>(context, listen: false)
                  .addProduct(newProduct);
              }
              
              // Tutup dialog setelah simpan
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METHOD _confirmDelete() - Dialog konfirmasi hapus produk
  // ==========================================================================
  // Parameter:
  // - context: BuildContext untuk dialog
  // - product: Product yang akan dihapus
  //
  // Konsep:
  // - Best practice: Selalu konfirmasi sebelum delete data
  // - Hindari accidental delete dengan dialog konfirmasi
  //
  // UI:
  // - AlertDialog dengan pesan konfirmasi
  // - Tombol "Batal" → Tutup dialog tanpa hapus
  // - Tombol "Hapus" merah → Hapus produk dari DB
  // ==========================================================================
  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // Title: Judul dialog
        title: const Text('Hapus Menu?'),
        
        // Content: Pesan konfirmasi dengan nama produk
        content: Text('Hapus menu "${product.name}"?'),
        
        // ====================================================================
        // DIALOG ACTIONS - Tombol Batal dan Hapus
        // ====================================================================
        actions: [
          // Tombol "Batal" → Tutup dialog tanpa hapus
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Batal')
          ),
          
          // Tombol "Hapus" → Hapus produk
          TextButton(
            onPressed: () {
              // Call provider untuk hapus produk dari DB
              Provider.of<ProductAdminProvider>(context, listen: false)
                .deleteProduct(product.id);
              
              // Tutup dialog konfirmasi
              Navigator.pop(ctx);
            },
            // Text merah untuk tombol hapus (warning style)
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CARA KERJA SCREEN INI:
// ============================================================================
//
// 1. User buka halaman "Manajemen Menu" (dari dashboard / drawer)
// 2. ProductAdminProvider.loadProducts() sudah dipanggil di dashboard
// 3. Screen build dengan data produk dari Provider
//
// 4. User klik filter chip (misal: "Minuman"):
//    - setState(() => _filter = 'Minuman')
//    - Widget rebuild
//    - filtered = products.where(category == 'Minuman')
//    - ListView tampilkan hanya produk kategori Minuman
//
// 5. User klik tombol + (FloatingActionButton):
//    - _showAddEditDialog(context, null) → product = null (mode tambah)
//    - Dialog form muncul dengan field kosong
//    - User isi form → Klik "Simpan"
//    - Provider.addProduct(newProduct)
//    - Product disimpan ke DB
//    - Provider.notifyListeners() → Screen rebuild otomatis
//    - Produk baru muncul di list
//
// 6. User klik menu "Edit" di PopupMenu:
//    - _showAddEditDialog(context, product) → product != null (mode edit)
//    - Dialog form muncul dengan field terisi data produk
//    - User ubah data → Klik "Update"
//    - Provider.updateProduct(newProduct)
//    - Product diupdate di DB
//    - Provider.notifyListeners() → Screen rebuild
//    - Produk terupdate di list
//
// 7. User klik menu "Hapus" di PopupMenu:
//    - _confirmDelete(context, product)
//    - Dialog konfirmasi muncul
//    - User klik "Hapus"
//    - Provider.deleteProduct(product.id)
//    - Product dihapus dari DB
//    - Provider.notifyListeners() → Screen rebuild
//    - Produk hilang dari list
//
// ============================================================================
// KONSEP PENTING:
// ============================================================================
//
// - StatefulWidget: Widget dengan state (_filter)
// - setState(): Trigger rebuild widget
// - Provider: State management untuk CRUD produk
// - ListView.builder: Efficient list rendering (hanya render yang visible)
// - ChoiceChip: Single-selection chip filter
// - PopupMenuButton: Menu dropdown (Edit/Delete)
// - AlertDialog: Modal dialog untuk form/konfirmasi
// - TextEditingController: Controller untuk input field
// - DropdownButtonFormField: Dropdown pilihan kategori
// - FloatingActionButton.extended: FAB dengan icon + label
//
// - Optimistic Update: UI update dulu, DB async
// - listen: false → Tidak subscribe perubahan (hanya call method)
// - listen: true → Subscribe perubahan (auto rebuild)
//
// ============================================================================
