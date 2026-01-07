import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/db/app_database.dart';
import 'core/prefs/app_prefs.dart';

import 'features/auth_owner/prefs/owner_auth_prefs.dart';
import 'features/auth_owner/ui/owner_login_screen.dart';
import 'owner_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure database is initialized and tables are created
  await AppDatabase.instance.database;

  // Read login state to decide initial route
  final loggedIn = await AppPrefs.getBool(OwnerAuthPrefs.keyLoggedIn) ?? false;

  runApp(MyApp(initialRoute: loggedIn ? '/owner' : '/owner-login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Owner POS',
      theme: AppTheme.light(),
      initialRoute: initialRoute,
      routes: {
        '/owner-login': (context) => const OwnerLoginScreen(),
        '/owner': (context) => const OwnerShell(),
      },
    );
  }
}
