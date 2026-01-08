import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../materials/repositories/material_repository.dart';
import '../../products/repositories/product_repository.dart';
import '../data/dashboard_repository.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final materialRepo = MaterialRepository();
    final productRepo = ProductRepository();
    final dashboardRepo = DashboardRepository();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        
        // Summary Cards
        FutureBuilder(
          future: Future.wait([
            materialRepo.count(),
            productRepo.count(),
            materialRepo.sumStock(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final values = snapshot.data as List<dynamic>;
            final materialCount = values[0] as int;
            final productCount = values[1] as int;
            final totalStock = values[2] as double;

            return Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Produk',
                    value: productCount.toString(),
                    icon: Icons.restaurant_menu,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Bahan',
                    value: materialCount.toString(),
                    icon: Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Stok',
                    value: totalStock.toStringAsFixed(2),
                    icon: Icons.bar_chart,
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Revenue Summary
        Text('Pendapatan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FutureBuilder(
          future: dashboardRepo.getRevenueSummary(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final data = snapshot.data as Map<String, dynamic>;
            final today = data['today'] as num;
            final thisWeek = data['thisWeek'] as num;
            final thisMonth = data['thisMonth'] as num;

            return Row(
              children: [
                Expanded(
                  child: _RevenueCard(
                    title: 'Hari Ini',
                    amount: today.toDouble(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RevenueCard(
                    title: 'Minggu Ini',
                    amount: thisWeek.toDouble(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RevenueCard(
                    title: 'Bulan Ini',
                    amount: thisMonth.toDouble(),
                    color: Colors.purple,
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Sales Chart - Last 7 Days
        Text('Penjualan 7 Hari Terakhir', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _SalesChart(dashboardRepo: dashboardRepo),
        
        const SizedBox(height: 24),
        
        // Top Products Chart
        Text('Produk Terlaris', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _TopProductsChart(dashboardRepo: dashboardRepo),
        
        const SizedBox(height: 24),
        
        // Low Stock Alert
        Text('Stok Bahan Menipis', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _LowStockAlert(dashboardRepo: dashboardRepo),
        
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.attach_money, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              formatter.format(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  final DashboardRepository dashboardRepo;

  const _SalesChart({required this.dashboardRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dashboardRepo.getSalesLast7Days(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data as List<Map<String, dynamic>>;
        
        if (data.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('Belum ada data penjualan', 
                  style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        }

        final spots = <FlSpot>[];
        final dates = <String>[];
        
        for (var i = 0; i < data.length; i++) {
          final total = (data[i]['total'] as num).toDouble();
          spots.add(FlSpot(i.toDouble(), total / 1000)); // Convert to thousands
          
          final dateStr = data[i]['date'] as String;
          final date = DateTime.parse(dateStr);
          dates.add(DateFormat('dd/MM').format(date));
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}k',
                            style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(dates[index],
                                style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopProductsChart extends StatelessWidget {
  final DashboardRepository dashboardRepo;

  const _TopProductsChart({required this.dashboardRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dashboardRepo.getTopProducts(limit: 5),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data as List<Map<String, dynamic>>;
        
        if (data.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('Belum ada data penjualan produk', 
                  style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        }

        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (data.first['quantity'] as int).toDouble() + 5,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}',
                                  style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < data.length) {
                                  // Show first 3 letters of product name
                                  final name = data[index]['name'] as String;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      name.length > 6 ? '${name.substring(0, 6)}.' : name,
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(data.length, (index) {
                          final qty = (data[index]['quantity'] as int).toDouble();
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: qty,
                                color: colors[index % colors.length],
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(data.length, (index) {
                        final name = data[index]['name'] as String;
                        final qty = data[index]['quantity'] as int;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$name ($qty)',
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LowStockAlert extends StatelessWidget {
  final DashboardRepository dashboardRepo;

  const _LowStockAlert({required this.dashboardRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dashboardRepo.getLowStockMaterials(threshold: 10),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data as List<Map<String, dynamic>>;
        
        if (data.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Semua stok bahan aman',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          color: Colors.orange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Perlu Restock',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.map((material) {
                  final name = material['name'] as String;
                  final stock = (material['stock'] as num).toDouble();
                  final unit = material['unit'] as String;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 14)),
                        Text(
                          '${stock.toStringAsFixed(1)} $unit',
                          style: TextStyle(
                            fontSize: 14,
                            color: stock < 5 ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
