import 'package:flutter/material.dart';

import 'core/db/app_database.dart';
import 'core/prefs/app_prefs.dart';

import 'features/auth_customer/prefs/auth_prefs.dart';
import 'features/auth_customer/ui/login_screen.dart';
import 'features/auth_customer/ui/register_screen.dart';
import 'features/cart_orders/ui/checkout_screen.dart';

import 'features/payments_history/ui/payment_screen.dart';

import 'home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure database is initialized and tables are created
  await AppDatabase.instance.database;

  // Read login state to decide initial route
  final loggedIn = await AppPrefs.getBool(AuthPrefs.keyLoggedIn) ?? false;

  runApp(MyApp(initialRoute: loggedIn ? '/menu' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lalana Kafe',
      theme: ThemeData(useMaterial3: true),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = (args is int) ? args : HomeTabs.menu;
          return HomeShell(initialIndex: initialIndex);
        },

        // Keep old routes, but show them inside the HomeShell tabs.
        '/menu': (context) => const HomeShell(initialIndex: HomeTabs.menu),
        '/cart': (context) => const HomeShell(initialIndex: HomeTabs.cart),
        '/history': (context) =>
            const HomeShell(initialIndex: HomeTabs.history),
        '/profile': (context) =>
            const HomeShell(initialIndex: HomeTabs.profile),

        '/checkout': (context) => const CheckoutScreen(),
        '/payment': (context) => const PaymentScreen(),
      },
    );
  }
}
