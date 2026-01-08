import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';

class DashboardRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  // Get sales data for the last 7 days
  Future<List<Map<String, dynamic>>> getSalesLast7Days() async {
    final db = await _db;
    
    // Get transactions from the last 7 days (using string comparison for ISO dates)
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    final result = await db.rawQuery('''
      SELECT 
        DATE(created_at) as date,
        SUM(total_amount) as total,
        COUNT(*) as count
      FROM transactions
      WHERE created_at >= ?
      GROUP BY DATE(created_at)
      ORDER BY date ASC
    ''', [sevenDaysAgo.toIso8601String()]);
    
    return result;
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    final db = await _db;
    
    // Parse items_json to count product sales
    final transactions = await db.query('transactions');
    
    final Map<String, dynamic> productStats = {};
    
    for (final tx in transactions) {
      final itemsJson = tx['items_json'] as String;
      // Simple parsing - assuming format like: [{"id":1,"name":"Espresso","qty":2}]
      final items = _parseItemsJson(itemsJson);
      
      for (final item in items) {
        final productName = item['name'] as String;
        final qty = item['qty'] as int;
        
        if (productStats.containsKey(productName)) {
          productStats[productName]['quantity'] += qty;
        } else {
          productStats[productName] = {'name': productName, 'quantity': qty};
        }
      }
    }
    
    final sortedProducts = productStats.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
    
    return sortedProducts.take(limit).map((e) => e as Map<String, dynamic>).toList();
  }

  // Get revenue summary
  Future<Map<String, dynamic>> getRevenueSummary() async {
    final db = await _db;
    
    // Get today's date range
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final today = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM transactions
      WHERE created_at >= ? AND created_at < ?
    ''', [todayStart.toIso8601String(), todayEnd.toIso8601String()]);
    
    // Get this week (last 7 days)
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM transactions
      WHERE created_at >= ?
    ''', [weekAgo.toIso8601String()]);
    
    // Get this month
    final monthStart = DateTime(now.year, now.month, 1);
    final thisMonth = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM transactions
      WHERE created_at >= ?
    ''', [monthStart.toIso8601String()]);
    
    return {
      'today': (today.first['total'] ?? 0) as num,
      'thisWeek': (thisWeek.first['total'] ?? 0) as num,
      'thisMonth': (thisMonth.first['total'] ?? 0) as num,
    };
  }

  // Get stock status (materials running low)
  Future<List<Map<String, dynamic>>> getLowStockMaterials({double threshold = 10}) async {
    final db = await _db;
    
    final result = await db.rawQuery('''
      SELECT id, name, stock, unit
      FROM materials
      WHERE stock < ?
      ORDER BY stock ASC
      LIMIT 5
    ''', [threshold]);
    
    return result;
  }

  List<Map<String, dynamic>> _parseItemsJson(String json) {
    // Simple JSON parsing for items
    // Format: [{"id":1,"name":"Espresso","qty":2}]
    try {
      final items = <Map<String, dynamic>>[];
      
      // Remove brackets
      String content = json.substring(1, json.length - 1);
      
      if (content.isEmpty) return items;
      
      // Split by },{ to get individual items
      final itemStrings = content.split('},{');
      
      for (var itemStr in itemStrings) {
        // Clean up brackets
        itemStr = itemStr.replaceAll('{', '').replaceAll('}', '');
        
        // Parse key-value pairs
        final pairs = itemStr.split(',');
        final Map<String, dynamic> item = {};
        
        for (final pair in pairs) {
          final kv = pair.split(':');
          if (kv.length == 2) {
            final key = kv[0].replaceAll('"', '').trim();
            var value = kv[1].replaceAll('"', '').trim();
            
            if (key == 'id' || key == 'qty' || key == 'quantity') {
              item[key] = int.tryParse(value) ?? 0;
            } else {
              item[key] = value;
            }
          }
        }
        
        items.add(item);
      }
      
      return items;
    } catch (e) {
      return [];
    }
  }
}
