import 'package:flutter/material.dart';
import '../features/kasir/ui/kasir_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cafeSync',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const KasirPage(),
    );
  }
}
