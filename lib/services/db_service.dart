import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../features/ingredient/models/ingredient.dart';
import '../features/category/models/category.dart';
import '../features/product/models/product.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'warung_demo.db');
    return await openDatabase(path, version: 3, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE orders(
          id TEXT PRIMARY KEY,
          customerName TEXT,
          phone TEXT,
          address TEXT,
          tableNumber TEXT,
          total INTEGER,
          itemsJson TEXT,
          paymentMethod TEXT,
          status TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId TEXT UNIQUE,
          productName TEXT,
          productPrice INTEGER,
          productImage TEXT,
          addedAt TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE promos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT UNIQUE,
          title TEXT,
          description TEXT,
          discountPercent INTEGER,
          minPurchase INTEGER,
          validUntil TEXT,
          isActive INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE order_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orderId TEXT UNIQUE,
          orderDate TEXT,
          totalAmount INTEGER,
          paymentMethod TEXT,
          status TEXT,
          itemsJson TEXT,
          rating INTEGER,
          review TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE ingredients(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          unit TEXT,
          quantity REAL,
          minStock REAL,
          price INTEGER,
          lastUpdated TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE,
          description TEXT,
          icon TEXT,
          sortOrder INTEGER,
          isActive INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE products(
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          price INTEGER,
          image TEXT,
          category TEXT,
          isAvailable INTEGER DEFAULT 1
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT UNIQUE,
            productName TEXT,
            productPrice INTEGER,
            productImage TEXT,
            addedAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS promos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE,
            title TEXT,
            description TEXT,
            discountPercent INTEGER,
            minPurchase INTEGER,
            validUntil TEXT,
            isActive INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS order_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId TEXT UNIQUE,
            orderDate TEXT,
            totalAmount INTEGER,
            paymentMethod TEXT,
            status TEXT,
            itemsJson TEXT,
            rating INTEGER,
            review TEXT
          )
        ''');
      }
      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ingredients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            unit TEXT,
            quantity REAL,
            minStock REAL,
            price INTEGER,
            lastUpdated TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            icon TEXT,
            sortOrder INTEGER,
            isActive INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS products(
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            price INTEGER,
            image TEXT,
            category TEXT,
            isAvailable INTEGER DEFAULT 1
          )
        ''');
      }
    });
  }

  // ========== INGREDIENTS CRUD ==========
  Future<void> insertIngredient(Ingredient ing) async {
    final d = await db;
    await d.insert('ingredients', ing.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ingredient>> getIngredients() async {
    final d = await db;
    final rows = await d.query('ingredients', orderBy: 'name ASC');
    return rows.map((r) => Ingredient.fromMap(r)).toList();
  }

  Future<void> updateIngredient(Ingredient ing) async {
    final d = await db;
    await d.update('ingredients', ing.toMap(), where: 'id = ?', whereArgs: [ing.id]);
  }

  Future<void> deleteIngredient(int id) async {
    final d = await db;
    await d.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateIngredientQuantity(int id, double newQuantity) async {
    final d = await db;
    await d.update(
      'ingredients',
      {'quantity': newQuantity, 'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CATEGORIES CRUD ==========
  Future<void> insertCategory(Category cat) async {
    final d = await db;
    await d.insert('categories', cat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final d = await db;
    final rows = await d.query('categories', orderBy: 'sortOrder ASC, name ASC');
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  Future<void> updateCategory(Category cat) async {
    final d = await db;
    await d.update('categories', cat.toMap(), where: 'id = ?', whereArgs: [cat.id]);
  }

  Future<void> deleteCategory(int id) async {
    final d = await db;
    await d.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ========== PRODUCTS CRUD (Admin) ==========
  Future<void> insertProduct(Product prod) async {
    final d = await db;
    final map = prod.toJson();
    map['isAvailable'] = 1;
    await d.insert('products', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Product>> getProducts() async {
    final d = await db;
    final rows = await d.query('products', orderBy: 'category ASC, name ASC');
    return rows.map((r) => Product.fromJson(r)).toList();
  }

  Future<void> updateProduct(Product prod) async {
    final d = await db;
    final map = prod.toJson();
    await d.update('products', map, where: 'id = ?', whereArgs: [prod.id]);
  }

  Future<void> deleteProduct(String id) async {
    final d = await db;
    await d.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleProductAvailability(String id, bool isAvailable) async {
    final d = await db;
    await d.update(
      'products',
      {'isAvailable': isAvailable ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

