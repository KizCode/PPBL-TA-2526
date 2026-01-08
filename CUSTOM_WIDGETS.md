# Custom Widgets Documentation

## Daftar Custom Widget

Aplikasi ini memiliki beberapa custom widget yang dapat digunakan kembali (reusable) untuk menjaga konsistensi tampilan dan mempercepat development.

### 1. StatCard & StatCardHorizontal
**Lokasi:** `lib/shared/widgets/stat_card.dart`

Widget untuk menampilkan statistik dengan icon, title, value, dan trend indicator.

**Features:**
- Icon dengan background color
- Trend indicator (naik/turun dengan persentase)
- Subtitle support
- Tap callback support
- Variant horizontal dan vertical

**Contoh Penggunaan:**
```dart
StatCard(
  title: 'Total Penjualan',
  value: 'Rp 150.000',
  icon: Icons.attach_money,
  color: Colors.green,
  trend: 12.5, // Menampilkan +12.5% dengan icon trending up
  subtitle: 'Hari ini',
  onTap: () => print('Card tapped'),
)
```

### 2. EmptyStateWidget, LoadingWidget, ErrorStateWidget
**Lokasi:** `lib/shared/widgets/state_widgets.dart`

Widget untuk menampilkan berbagai state aplikasi dengan tampilan yang konsisten dan user-friendly.

**EmptyStateWidget Features:**
- Icon dengan circular background
- Title dan message
- Action button optional
- Customizable color

**LoadingWidget Features:**
- Circular progress indicator
- Optional loading message
- Customizable color

**ErrorStateWidget Features:**
- Error icon dengan circular background
- Title dan error message
- Retry button optional

**Contoh Penggunaan:**
```dart
// Empty state
EmptyStateWidget(
  icon: Icons.shopping_cart,
  title: 'Keranjang Kosong',
  message: 'Belum ada produk di keranjang',
  actionLabel: 'Mulai Belanja',
  onActionPressed: () => Navigator.push(...),
)

// Loading state
LoadingWidget(
  message: 'Memuat data...',
)

// Error state
ErrorStateWidget(
  title: 'Gagal Memuat Data',
  message: 'Terjadi kesalahan saat memuat data',
  onRetry: () => _loadData(),
)
```

### 3. CustomTextField, CustomDropdown, CustomButton
**Lokasi:** `lib/shared/widgets/custom_form_fields.dart`

Widget untuk form input dengan styling konsisten dan fitur validasi.

**CustomTextField Features:**
- Prefix dan suffix icon support
- Validasi bawaan
- Obscure text untuk password
- Input formatter support
- Max length counter
- Enable/disable state

**CustomDropdown Features:**
- Generic type support
- Validasi bawaan
- Custom item label
- Consistent styling

**CustomButton Features:**
- Loading state otomatis
- Icon support
- Outlined variant
- Custom colors
- Disabled state saat loading

**Contoh Penggunaan:**
```dart
// Text field
CustomTextField(
  controller: _nameController,
  label: 'Nama Produk',
  hint: 'Masukkan nama produk',
  prefixIcon: Icons.shopping_bag,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Nama produk harus diisi';
    }
    return null;
  },
)

// Dropdown
CustomDropdown<String>(
  value: _selectedUnit,
  items: ['kg', 'gram', 'liter', 'ml'],
  label: 'Satuan',
  prefixIcon: Icons.scale,
  itemLabel: (unit) => unit,
  onChanged: (value) => setState(() => _selectedUnit = value),
)

// Button dengan loading
CustomButton(
  label: 'Simpan',
  icon: Icons.save,
  isLoading: _isLoading,
  onPressed: _isLoading ? null : () => _saveData(),
)
```

### 4. MenuCard (Kasir)
**Lokasi:** `lib/features/kasir/widgets/menu_card.dart`

Widget untuk menampilkan item menu di kasir dengan info stok dan tombol tambah.

### 5. MenuCard (Customer)
**Lokasi:** `lib/features/customer/widgets/menu_card.dart`

Widget untuk menampilkan item menu di customer dengan info stok dan harga.

### 6. ProductCard
**Lokasi:** `lib/features/products/ui/widgets/product_card.dart`

Widget untuk menampilkan produk di owner dashboard dengan aksi edit dan delete.

### 7. MaterialCard
**Lokasi:** `lib/features/materials/ui/widgets/material_card.dart`

Widget untuk menampilkan bahan di owner dashboard dengan info stok dan aksi.

### 8. RecipeInputWidget
**Lokasi:** `lib/features/products/ui/widgets/recipe_input_widget.dart`

Widget kompleks untuk input resep produk (bahan dan jumlah yang dibutuhkan).

### 9. CartItemCard
**Lokasi:** `lib/features/customer/widgets/cart_item_card.dart`

Widget untuk menampilkan item di keranjang customer dengan kontrol kuantitas.

### 10. CustomAppBar & PrimaryButton
**Lokasi:** 
- `lib/features/customer/widgets/custom_app_bar.dart`
- `lib/features/customer/widgets/primary_button.dart`

Widget untuk AppBar dan Button dengan styling custom di customer app.

## Theming

**Lokasi:** `lib/app_theme.dart`

Aplikasi menggunakan Material Design 3 dengan tema yang konsisten:

**Color Scheme:**
- Primary Green: `#22C55E`
- Light Green: `#EFF3E9`
- Dark Green: `#1B5E20`

**Features:**
- Light theme dengan seed color dari primary green
- AppBar styling konsisten
- ElevatedButton dengan rounded corners
- Card dengan elevation dan border radius
- InputDecoration dengan outline border
- BottomNavigationBar styling
- FloatingActionButton styling

## Navigation

### Owner App - Drawer Navigation
**Lokasi:** `lib/owner_shell.dart`

Owner menggunakan **Drawer** untuk navigasi antar halaman:
- Dashboard (dengan charts)
- Bahan (materials management)
- Produk (product management)
- Logout

### Customer App - Bottom Navigation Bar
**Lokasi:** `lib/home_shell.dart`

Customer menggunakan **BottomNavigationBar** dengan 4 tabs:
- Menu (browse produk)
- Cart (keranjang belanja)
- History (riwayat transaksi)
- Profile (profil pengguna)

### Kasir App - Single Page
**Lokasi:** `lib/kasir_shell.dart`

Kasir menggunakan single page dengan semua fitur POS di satu layar.

## Best Practices

1. **Gunakan custom widgets untuk konsistensi**
   - Semua card menggunakan styling yang sama
   - Semua button menggunakan theme yang konsisten
   
2. **Reusable components**
   - Widget dapat digunakan di berbagai tempat
   - Parameter yang fleksibel untuk customization
   
3. **Type-safe dengan Generics**
   - CustomDropdown menggunakan generic type
   - Aman dari error runtime
   
4. **Proper state management**
   - Loading state untuk async operations
   - Error handling dengan retry mechanism
   - Empty state untuk user feedback

5. **Accessibility**
   - Semua widget memiliki semantic label
   - Proper contrast ratio untuk colors
   - Touch target size yang cukup
