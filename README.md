# CafeSync - Admin Panel

Aplikasi manajemen cafe/warung dengan admin panel untuk kelola produk, stok bahan, dan kategori menu.

## 🎯 Fitur Utama

### Admin Panel
- **Dashboard** - Ringkasan data produk, stok bahan, dan kategori
- **Manajemen Produk** - CRUD menu dengan upload gambar
- **Manajemen Stok** - Kelola stok bahan dengan alert stok rendah
- **Manajemen Kategori** - Kelola kategori menu (Makanan, Minuman, dll)

### Customer
- **Menu Browsing** - Lihat menu dengan filter kategori
- **Search** - Cari produk

## 🏗️ Arsitektur

Aplikasi menggunakan **Feature-First Architecture** dengan struktur:

```
lib/
├── features/           # Feature modules
│   ├── product/       # Manajemen produk
│   ├── ingredient/    # Manajemen stok bahan
│   ├── category/      # Manajemen kategori
│   ├── dashboard/     # Dashboard admin
│   └── menu/          # Menu customer
├── services/          # Database & API
├── widgets/           # Reusable widgets
└── main.dart          # Entry point
```

Setiap feature memiliki:
- `models/` - Data structures
- `providers/` - State management (Provider pattern)
- `screens/` - UI components

## 🚀 Cara Menjalankan

1. Install Flutter dan setup environment
2. Install dependencies:
```bash
flutter pub get
```

3. Run aplikasi:
```bash
flutter run
```

4. Pilih device (Chrome/Android/iOS/Desktop)

## 💾 Database

Aplikasi menggunakan **SQLite** untuk penyimpanan lokal:
- `lib/services/db_service.dart` - Database service
- Tables: products, ingredients, categories

## 🛠️ Teknologi

- **Flutter** - UI Framework
- **Provider** - State Management
- **SQLite** (sqflite) - Local Database
- **Image Picker** - Upload gambar produk

## 📁 Struktur Fitur

### Product (Produk)
- Model: `features/product/models/product.dart`
- Provider: `features/product/providers/product_admin_provider.dart`
- Screen: `features/product/screens/admin_product_screen.dart`

### Ingredient (Stok Bahan)
- Model: `features/ingredient/models/ingredient.dart`
- Provider: `features/ingredient/providers/ingredient_provider.dart`
- Screen: `features/ingredient/screens/admin_ingredient_screen.dart`

### Category (Kategori)
- Model: `features/category/models/category.dart`
- Provider: `features/category/providers/category_provider.dart`
- Screen: `features/category/screens/admin_category_screen.dart`

## 🔧 Build untuk Production

Gunakan build script:
```powershell
.\build_optimized.ps1
```

Atau manual:
```bash
# Web
flutter build web --release

# Android
flutter build apk --release --split-per-abi

# Windows
flutter build windows --release
```

## 📝 Catatan

- Database akan otomatis dibuat saat pertama kali run
- Gambar produk disimpan sebagai base64 di database
- Mock API menggunakan `assets/menu.json` untuk testing

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Flutter](https://pub.dev/packages/sqflite)
