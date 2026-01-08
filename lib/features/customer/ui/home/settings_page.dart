import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Tema'),
            subtitle: Text('Sesuaikan tampilan aplikasi'),
          ),
          ListTile(
            title: const Text('Mode Tema'),
            subtitle: Text(isDarkMode ? 'Mode Gelap' : 'Mode Terang'),
            leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            trailing: const Text('Otomatis (Sistem)'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tema mengikuti pengaturan sistem perangkat Anda',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Bahasa'),
            subtitle: Text('Pilih bahasa aplikasi'),
            trailing: Text('Indonesia'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifikasi'),
            subtitle: Text('Kelola pengaturan notifikasi'),
          ),
          SwitchListTile(
            title: const Text('Notifikasi Pesanan'),
            subtitle: const Text('Dapatkan update status pesanan'),
            value: true, // Default on
            onChanged: (value) {
              // Implement notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fitur notifikasi akan segera hadir')),
              );
            },
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privasi'),
            subtitle: Text('Kelola data pribadi & keamanan'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tentang'),
            subtitle: Text('Versi aplikasi & informasi'),
          ),
        ],
      ),
    );
  }
}
