import 'package:flutter/material.dart';

import 'features/cart_orders/ui/cart_screen.dart';
import 'features/cart_orders/ui/menu_list_screen.dart';
import 'features/payments_history/ui/history_screen.dart';
import 'features/auth_customer/prefs/auth_prefs.dart';
import 'features/auth_customer/ui/profile_screen.dart';

class HomeTabs {
  static const int menu = 0;
  static const int cart = 1;
  static const int history = 2;
  static const int profile = 3;
}

class HomeShell extends StatefulWidget {
  final int initialIndex;

  const HomeShell({super.key, this.initialIndex = HomeTabs.menu});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;
  bool _checkedAuth = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(HomeTabs.menu, HomeTabs.profile);
    _guardAuth();
  }

  Future<void> _guardAuth() async {
    final loggedIn = await AuthPrefs.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      return;
    }

    if (mounted) {
      setState(() => _checkedAuth = true);
    }
  }

  void setIndex(int newIndex) {
    final clamped = newIndex.clamp(HomeTabs.menu, HomeTabs.profile);
    if (clamped == _index) return;
    setState(() => _index = clamped);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomeShellScope(
      index: _index,
      setIndex: setIndex,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            MenuListScreen(),
            CartScreen(),
            HistoryScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: setIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class HomeShellScope extends InheritedWidget {
  final int index;
  final ValueChanged<int> setIndex;

  const HomeShellScope({
    super.key,
    required this.index,
    required this.setIndex,
    required super.child,
  });

  static HomeShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeShellScope>();
  }

  @override
  bool updateShouldNotify(HomeShellScope oldWidget) {
    return oldWidget.index != index;
  }
}
