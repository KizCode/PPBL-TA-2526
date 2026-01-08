import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth_customer/ui/profile_screen.dart';
import 'features/customer/providers/menu_provider.dart';
import 'features/customer/ui/auth/login_page.dart';
import 'features/customer/ui/auth/register_page.dart';
import 'features/customer/ui/home/home_shell_page.dart';
import 'features/customer/ui/menu/main_menu_page.dart';
import 'features/customer/ui/order/cart_checkout_page.dart';
import 'features/customer/ui/order/cart_state.dart';
import 'features/settings/ui/settings_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await CartState.instance.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = MenuProvider();
            provider.loadMenuItems();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'cafeSync Customer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            initialRoute: '/login',
            routes: {
              '/login': (_) => const LoginPage(),
              '/register': (_) => const RegisterPage(),
              '/home': (_) => const HomeShellPage(),
              '/menu': (_) => const MainMenuPage(),
              '/cart': (_) => const CartCheckoutPage(),
              '/profile': (_) => const ProfileScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
