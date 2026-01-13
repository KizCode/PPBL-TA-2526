import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../../auth_customer/prefs/auth_prefs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final identityCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    identityCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onLogin() async {
    // Validasi form
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulasi API

    // Simpan data login
    final email = identityCtrl.text.trim();
    await AuthPrefs.setLoggedIn(true);
    await AuthPrefs.setUserId(1); // Default user ID
    await AuthPrefs.setUsername(email);

    // Simpan data akun (untuk sementara gunakan email sebagai nama jika belum ada)
    if (email.contains('@')) {
      await AuthPrefs.setEmail(email);
      await AuthPrefs.setFullName(email.split('@')[0]); // Nama dari email
    } else {
      await AuthPrefs.setPhone(email);
      await AuthPrefs.setFullName('User');
    }

    setState(() => loading = false);

    _showSnack('Login berhasil');

    if (!mounted) return;

    // Navigate to home
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_cafe,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Masuk ke Akun Anda',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Email / Nomor Telepon
                  TextFormField(
                    controller: identityCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Email atau Nomor Telepon',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Isi email/no telp.';
                      if (!t.contains('@') && t.length < 8) {
                        return 'Masukkan email valid atau nomor telepon yang benar.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Kata Sandi
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => loading ? null : _onLogin(),
                    decoration: InputDecoration(
                      hintText: 'Kata Sandi',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                        tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
                      ),
                    ),
                    validator: (v) {
                      final t = v ?? '';
                      if (t.isEmpty) return 'Isi kata sandi.';
                      if (t.length < 6) return 'Minimal 6 karakter.';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tombol Masuk
                  PrimaryButton(
                    text: 'Masuk',
                    isLoading: loading,
                    onPressed: _onLogin,
                  ),

                  const SizedBox(height: 8),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: loading
                          ? null
                          : () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Daftar Akun Baru'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lanjut tanpa login
                  GestureDetector(
                    onTap: () async {
                      if (loading) return;

                      // Simpan sebagai guest
                      await AuthPrefs.setLoggedIn(true);
                      await AuthPrefs.setUserId(0); // Guest user
                      await AuthPrefs.setUsername('Guest');
                      await AuthPrefs.setFullName('Guest User');
                      await AuthPrefs.setEmail('-');
                      await AuthPrefs.setPhone('-');

                      _showSnack('Lanjut sebagai Guest');
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;

                      Navigator.pushNamed(context, '/home');
                    },
                    child: const Text(
                      'Lanjut tanpa login',
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
