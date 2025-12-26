// ============================================================================
// PRODUCT MODEL - Blueprint untuk Data Menu/Produk
// ============================================================================
// Model = Template/cetakan untuk membuat object dengan struktur tertentu
// Seperti blueprint rumah: ada ruang tamu, kamar, dapur (property tetap)
// 
// Fungsi Model:
// 1. Mendefinisikan struktur data (field apa saja yang ada)
// 2. Type safety (harus sesuai tipe data: String, int, bool, dll)
// 3. Konversi data: JSON ↔ Object ↔ Database Map
// ============================================================================

class Product {
  // ==========================================================================
  // PROPERTIES - Data yang dimiliki setiap produk
  // ==========================================================================
  // final = Tidak bisa diubah setelah dibuat (immutable)
  // Keuntungan immutable: Aman dari perubahan tidak sengaja, predictable
  
  final String id;           // ID unik produk (misal: "P001", "P002")
  final String name;         // Nama produk (misal: "Espresso", "Cappuccino")
  final String description;  // Deskripsi produk (misal: "Kopi hitam pekat")
  final int price;           // Harga dalam rupiah (misal: 25000)
  final String image;        // URL gambar produk (untuk ditampilkan)
  final String category;     // Kategori (misal: "Coffee", "Snack", "Dessert")

  // ==========================================================================
  // CONSTRUCTOR - Cara membuat object Product
  // ==========================================================================
  // required = Field wajib diisi saat membuat product baru
  // 
  // Contoh penggunaan:
  // Product espresso = Product(
  //   id: 'P001',
  //   name: 'Espresso',
  //   description: 'Kopi hitam pekat',
  //   price: 25000,
  //   image: 'https://...',
  //   category: 'Coffee'
  // );
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category
  });

  // ==========================================================================
  // FACTORY CONSTRUCTOR - Membuat Product dari JSON/Map
  // ==========================================================================
  // Dipakai saat:
  // 1. Terima data dari API (format JSON)
  // 2. Baca data dari database SQLite (format Map)
  // 
  // JSON contoh:
  // {
  //   "id": "P001",
  //   "name": "Espresso",
  //   "price": 25000,
  //   ...
  // }
  //
  // Operator ?? = Null coalescing (jika null, pakai nilai default)
  // json['name'] ?? '' → Kalau name null, pakai string kosong ''
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'].toString(),                    // Convert ke String
    name: json['name'] ?? '',                     // Default: string kosong
    description: json['description'] ?? '',
    price: (json['price'] ?? 0) as int,           // Default: 0
    image: json['image'] ?? '',
    category: json['category'] ?? 'Umum',         // Default: kategori "Umum"
  );

  // ==========================================================================
  // METHOD toJson() - Convert Product ke Map/JSON
  // ==========================================================================
  // Dipakai saat:
  // 1. Simpan data ke database SQLite
  // 2. Kirim data ke API
  // 
  // Product object → Map/JSON → Database/API
  // 
  // Contoh hasil:
  // {
  //   "id": "P001",
  //   "name": "Espresso",
  //   "price": 25000,
  //   ...
  // }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
  };
}

// ============================================================================
// FLOW DATA LENGKAP:
// ============================================================================
//
// 1. DARI DATABASE KE UI:
//    Database (Map) → fromJson() → Product Object → UI tampilkan
//
// 2. DARI UI KE DATABASE:
//    User input → Product Object → toJson() → Map → Database simpan
//
// 3. CONTOH PENGGUNAAN:
//    
//    // Buat product baru
//    Product newProduct = Product(
//      id: DateTime.now().millisecondsSinceEpoch.toString(),
//      name: nameController.text,
//      description: descController.text,
//      price: int.parse(priceController.text),
//      image: imageUrl,
//      category: selectedCategory,
//    );
//
//    // Simpan ke database
//    await DBService().insertProduct(newProduct);
//
//    // Ambil dari database
//    List<Map> rawData = await db.query('products');
//    List<Product> products = rawData.map((map) => 
//      Product.fromJson(map)
//    ).toList();
//
// ============================================================================
