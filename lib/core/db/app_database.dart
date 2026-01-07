import 'package:sqflite/sqflite.dart';

import '../../features/auth_customer/data/user_db.dart';
import '../../features/cart_orders/data/cart_db.dart';
import '../../features/payments_history/data/transaction_db.dart';

import '../../features/materials/data/material_db.dart';
import '../../features/products/data/product_db.dart';
import '../../features/products/data/recipe_db.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = '${await getDatabasesPath()}/lalana_kafe.db';
    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(UserDb.createTableSql);
    await db.execute(CartDb.createTableSql);
    await db.execute(TransactionDb.createTableSql);

    await db.execute(MaterialDb.createTableSql);
    await db.execute(ProductDb.createTableSql);
    await db.execute(RecipeDb.createTableSql);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(MaterialDb.createTableSql);
      await db.execute(ProductDb.createTableSql);
      await db.execute(RecipeDb.createTableSql);
    }
  }
}
