import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/admin/settings';
  final void Function(ThemeMode?)? onThemeChanged;
  final ThemeMode? currentThemeMode;

  const SettingsScreen({Key? key, this.onThemeChanged, this.currentThemeMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Tema'),
            subtitle: Text('Pilih mode terang/gelap'),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Ikuti Sistem'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: onThemeChanged,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Terang'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: onThemeChanged,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Gelap'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }
}
