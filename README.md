# CafeSync - Aplikasi POS Cafe

Aplikasi Point of Sale (POS) lengkap untuk cafe dengan 3 mode akses: Owner, Kasir, dan Customer. Aplikasi ini dilengkapi dengan manajemen inventory berbasis resep, stock calculation otomatis, dan dashboard analytics.

## 🎯 Fitur Utama

### 👨‍💼 Owner Mode
- **Dashboard dengan Analytics**
  - Revenue summary (hari ini, minggu ini, bulan ini)
  - Sales trend chart (7 hari terakhir)
  - Top products bar chart
  - Low stock alert untuk bahan
  - Summary cards (total produk, bahan, stok)
  
- **Manajemen Bahan (Materials)**
  - CRUD bahan baku
  - Tracking stok dengan satuan (kg, gram, liter, ml)
  - Alert otomatis untuk stok menipis
  
- **Manajemen Produk (Products)**
  - CRUD menu produk
  - Recipe management (komposisi bahan per produk)
  - Stock calculation otomatis berdasarkan ketersediaan bahan
  - Harga dan deskripsi produk

- **Navigation:** Drawer dengan menu Dashboard, Bahan, dan Produk

### 👨‍💻 Kasir Mode
- **POS Interface**
  - Menu produk dengan info stok real-time
  - Keranjang belanja dengan total otomatis
  - Metode pembayaran: Tunai dan Non-tunai
  - Kalkulasi kembalian otomatis
  - Material stock reduction otomatis saat transaksi
  
- **Features:**
  - Add to cart dengan quantity control
  - Real-time stock update
  - Payment confirmation
  - Auto refresh stock setelah pembayaran

### 👤 Customer Mode
- **Menu Browsing**
  - Lihat semua menu dengan foto
  - Info harga dan stok real-time
  - Stock calculated dari ketersediaan bahan
  
- **Shopping Cart**
  - Tambah/kurang quantity
  - Total otomatis dengan format Rupiah
  - Catatan untuk setiap item
  
- **Checkout**
  - Pilih metode pembayaran (QRIS, E-Wallet, Mobile Banking, Cash)
  - Material stock reduction otomatis
  - Konfirmasi pembayaran
  
- **History & Profile**
  - Riwayat transaksi
  - Manajemen profil pengguna
  
- **Navigation:** Bottom Navigation Bar (Menu, Cart, History, Profile)

## 🎨 Custom Widgets

Aplikasi ini dilengkapi dengan **10+ custom widgets** yang reusable:

### Shared Widgets
1. **StatCard & StatCardHorizontal** - Statistik cards dengan trend indicator
2. **EmptyStateWidget** - Empty state dengan icon dan action button
3. **LoadingWidget** - Loading indicator dengan message
4. **ErrorStateWidget** - Error state dengan retry button
5. **CustomTextField** - Text input dengan validasi dan styling konsisten
6. **CustomDropdown** - Dropdown dengan generic type support
7. **CustomButton** - Button dengan loading state

### Feature-Specific Widgets
8. **MenuCard** - Display menu items (Kasir & Customer)
9. **ProductCard** - Display products di owner dashboard
10. **MaterialCard** - Display materials dengan stock info
11. **RecipeInputWidget** - Complex widget untuk input resep produk
12. **CartItemCard** - Display cart items dengan quantity control

📖 **Detail lengkap:** Lihat [CUSTOM_WIDGETS.md](CUSTOM_WIDGETS.md)

## 🎨 Theming

Aplikasi menggunakan **Material Design 3** dengan tema konsisten:

**Color Scheme:**
- Primary Green: `#22C55E`
- Light Green: `#EFF3E9`
- Dark Green: `#1B5E20`

**Lokasi:** `lib/app_theme.dart`

**Features:**
- AppBar dengan background color konsisten
- ElevatedButton dengan rounded corners
- Card elevation dan border radius
- Bottom Navigation Bar styling
- Form input dengan outline border

## 🧭 Navigation Patterns

1. **Owner:** Drawer Navigation
   - Dashboard, Bahan, Produk, Logout
   
2. **Customer:** Bottom Navigation Bar
   - Menu, Cart, History, Profile
   
3. **Kasir:** Single Page POS Interface

## 🏗️ Arsitektur

**Feature-First Architecture** dengan struktur:

```
lib/
├── features/              # Feature modules
│   ├── auth_owner/       # Owner authentication
│   ├── auth_customer/    # Customer authentication
│   ├── dashboard/        # Owner dashboard dengan charts
│   │   ├── ui/
│   │   └── data/         # Dashboard repository
│   ├── materials/        # Material management
│   │   ├── ui/
│   │   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   ├── products/         # Product management + recipes
│   │   ├── ui/
│   │   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   ├── kasir/           # POS kasir
│   │   ├── ui/
│   │   ├── data/
│   │   ├── models/
│   │   └── widgets/
│   ├── customer/        # Customer app
│   │   ├── ui/
│   │   ├── providers/
│   │   └── widgets/
│   ├── cart_orders/     # Shopping cart
│   └── payments_history/ # Transaction history
├── core/
│   ├── db/              # SQLite database
│   └── router/          # Navigation routes
├── shared/
│   └── widgets/         # Reusable custom widgets
├── app_theme.dart       # Material Design 3 theme
├── main.dart            # Entry point
├── owner_shell.dart     # Owner navigation shell (Drawer)
├── home_shell.dart      # Customer navigation shell (BottomNav)
└── kasir_shell.dart     # Kasir shell
```

## 💾 Database Schema

**SQLite Database:** `lalana_kafe.db`

### Tables:
1. **materials** - Bahan baku
   - id, name, unit, stock
   
2. **products** - Menu produk
   - id, name, price, stock (calculated)
   
3. **product_materials** - Recipe/komposisi produk
   - product_id, material_id, qty
   
4. **users** - Customer users
   
5. **cart** - Shopping cart items
   
6. **transactions** - Payment history
   - id, user_id, total_amount, payment_method, status, items_json, created_at

### Stock Calculation Algorithm:
```dart
// Untuk setiap produk, hitung stok berdasarkan bahan
for (product in products) {
  availableStock = MIN(
    for (material in recipe) {
      materialStock / recipeQuantity
    }
  )
}
```

## 📊 Charts & Analytics

Owner dashboard menggunakan **fl_chart** untuk visualisasi data:

1. **Line Chart** - Sales trend 7 hari terakhir
2. **Bar Chart** - Top 5 produk terlaris
3. **Revenue Cards** - Summary pendapatan (hari/minggu/bulan)
4. **Low Stock Alert** - List bahan yang perlu restock

## 🔐 Authentication

- Owner login: Username & Password (SQLite)
- Customer login: Email & Password (SQLite)
- Secure storage menggunakan `flutter_secure_storage`

## 📦 Dependencies

```yaml
dependencies:
  flutter_sdk: ^3.10.1
  sqflite: ^2.2.8+4          # Database
  provider: ^6.0.5            # State management
  fl_chart: ^0.69.0           # Charts
  intl: ^0.19.0               # Formatting (currency, date)
  shared_preferences: ^2.2.2  # Local storage
  flutter_secure_storage: ^9.0.0  # Secure storage
  image_picker: ^1.0.7        # Image upload
  uuid: ^4.0.0                # ID generation
```

## 🚀 Cara Menjalankan

1. **Install Flutter** (versi 3.10.1 atau lebih baru)
   ```bash
   flutter doctor
   ```

2. **Clone repository**
   ```bash
   git clone <repository-url>
   cd PPBL-TA-2526
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run aplikasi**
   ```bash
   flutter run
   ```

5. **Build APK**
   ```bash
   flutter build apk --release
   ```

## 👥 Login Credentials

### Owner
- Route: `/owner-login`
- Username: `owner`
- Password: `owner123`

### Kasir
- Route: `/kasir`
- Langsung akses (no auth)

### Customer
- Route: `/login`
- Email: `user@example.com`
- Password: `password`

## ✅ Checklist Requirement

- ✅ **Theming** - Material Design 3 dengan color scheme konsisten
- ✅ **Custom Widget** - 12+ custom widgets yang reusable
- ✅ **Navigation Bar/Drawer** 
  - Owner: Drawer navigation
  - Customer: Bottom Navigation Bar
  - Kasir: Single page interface
- ✅ **State Management** - Provider pattern
- ✅ **Database** - SQLite dengan migration support
- ✅ **Charts** - fl_chart untuk analytics
- ✅ **Authentication** - Secure login untuk Owner & Customer
- ✅ **CRUD Operations** - Materials, Products, Recipes
- ✅ **Real-time Stock** - Calculated dari materials
- ✅ **Transaction Flow** - Cart → Checkout → Payment → Stock Reduction

## 📝 Fitur Unggulan

1. **Automatic Stock Calculation**
   - Stok produk dihitung otomatis dari ketersediaan bahan
   - Algorithm: MIN(material_stock / recipe_quantity)
   
2. **Material Reduction on Sale**
   - Saat transaksi sukses, stok bahan berkurang otomatis
   - Transaction-based untuk atomic updates
   
3. **Dashboard Analytics**
   - Real-time charts dari data transaksi
   - Revenue tracking per periode
   - Product popularity analytics
   
4. **Recipe Management**
   - Setiap produk punya resep (list bahan + qty)
   - Flexible material units (kg, gram, liter, ml)
   
5. **Responsive UI**
   - Adaptive layout untuk berbagai screen size
   - Material Design 3 components
   
6. **Data Persistence**
   - SQLite untuk offline-first
   - Migration support untuk schema changes

## 📄 License

MIT License

## 👨‍💻 Developer

PPBL-TA-2526 Team

**Feature-First Architecture** dengan struktur:

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
