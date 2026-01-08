import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'core/db/app_database.dart';
import 'core/prefs/app_prefs.dart';
import 'core/providers/theme_provider.dart';

import 'features/auth_owner/prefs/owner_auth_prefs.dart';
import 'features/auth_owner/ui/owner_login_screen.dart';
import 'features/kasir/data/kasir_database.dart';
import 'features/settings/ui/settings_screen.dart';
import 'features/customer/ui/auth/login_page.dart';
import 'owner_shell.dart';
import 'kasir_shell.dart';
import 'customer_shell.dart';
import 'home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure database is initialized and tables are created
  await AppDatabase.instance.database;
  
  // Initialize dummy data (materials, products, recipes)
  await DatabaseHelper.instance.initializeDummyData();

  // Read login state to decide initial route
  final loggedIn = await AppPrefs.getBool(OwnerAuthPrefs.keyLoggedIn) ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(initialRoute: loggedIn ? '/owner' : '/'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'cafeSync POS',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            '/': (context) => const HomePage(),
            '/owner-login': (context) => const OwnerLoginScreen(),
            '/owner': (context) => const OwnerShell(),
            '/kasir': (context) => const KasirShell(),
            '/customer': (context) => const CustomerShell(),
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomeShell(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cafeSync POS'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_cafe,
                size: 80,
                color: Colors.brown,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/owner-login');
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Owner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/kasir');
                  },
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Kasir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/customer');
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
