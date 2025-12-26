import 'dart:convert';
import 'package:flutter/services.dart';
import '../features/product/models/product.dart';

// MockApi service reads from local asset `assets/menu.json`.
// Replace with real network calls if you later add a backend.
class MockApi {
  Future<List<Product>> fetchMenu() async {
    final data = await rootBundle.loadString('assets/menu.json');
    final arr = json.decode(data) as List<dynamic>;
    return arr.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Simulate order submission, returns order id
  Future<String> submitOrder(Map<String, dynamic> order) async {
    await Future.delayed(Duration(seconds: 1));
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
