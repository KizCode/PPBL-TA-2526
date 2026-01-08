import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'features/kasir/ui/kasir_page.dart';

class KasirShell extends StatelessWidget {
  const KasirShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cafeSync Kasir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const KasirPage(),
    );
  }
}
