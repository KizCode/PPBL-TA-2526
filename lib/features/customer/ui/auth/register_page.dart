
import 'package:flutter/material.dart';
import '../../../auth_customer/prefs/auth_prefs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller form
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool agree = false;   // checkbox S&K
  bool loading = false; // state tombol
  bool obscure1 = true;
  bool obscure2 = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isValidEmail(String email) {
    final re = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
    return re.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 15; // contoh range umum
  }

  bool _isStrongPassword(String pwd) {
    // Minimal 6–8 karakter sudah cukup untuk simulasi.
    // Kalau mau kuat: huruf besar, kecil, angka, simbol.
    if (pwd.length < 6) return false;
    return true;
    // Untuk versi kuat, pakai ini:
    // final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    // return re.hasMatch(pwd);
  }

  Future<void> _onRegister() async {
    if (!formKey.currentState!.validate()) return;
    if (!agree) { _showSnack('Setujui Syarat & Ketentuan.'); return; }

    setState(() => loading = true);

    // TODO: Panggil API register ke backend kamu di sini.
    // await AuthService.register(
    //   fullName: nameCtrl.text.trim(),
    //   email: emailCtrl.text.trim(),
    //   phone: phoneCtrl.text.trim(),
    //   password: passCtrl.text,
    // );

    await Future.delayed(const Duration(seconds: 1)); // simulasi
    
    // Simpan data registrasi ke SharedPreferences
    await AuthPrefs.setLoggedIn(true);
    await AuthPrefs.setUserId(1); // Default user ID
    await AuthPrefs.setUsername(emailCtrl.text.trim().isNotEmpty 
      ? emailCtrl.text.trim() 
      : phoneCtrl.text.trim());
    await AuthPrefs.setFullName(nameCtrl.text.trim());
    await AuthPrefs.setEmail(emailCtrl.text.trim());
    await AuthPrefs.setPhone(phoneCtrl.text.trim());
    
    setState(() => loading = false);
    _showSnack('Registrasi berhasil');

    if (!mounted) return;

    // Langsung ke HomeShell setelah daftar
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Akun Baru'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ilustrasi/Avatar (opsional)
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.emoji_people, size: 40, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Daftar Akun Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Nama Lengkap
                const Text('Nama Lengkap'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap Anda',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Nama lengkap wajib diisi.';
                    if (t.length < 3) return 'Nama minimal 3 karakter.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Email
                const Text('Email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat email Anda',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty && (phoneCtrl.text.trim().isEmpty)) {
                      return 'Isi email atau nomor telepon.';
                    }
                    if (t.isNotEmpty && !_isValidEmail(t)) {
                      return 'Format email tidak valid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Nomor Telepon
                const Text('Nomor Telepon'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nomor telepon Anda',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if ((emailCtrl.text.trim().isEmpty) && t.isEmpty) {
                      return 'Isi email atau nomor telepon.';
                    }
                    if (t.isNotEmpty && !_isValidPhone(t)) {
                      return 'Nomor telepon tidak valid (10–15 digit).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Kata Sandi
                const Text('Kata Sandi'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: passCtrl,
                  obscureText: obscure1,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Buat kata sandi',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscure1 = !obscure1),
                    ),
                  ),
                  validator: (v) {
                    final t = v ?? '';
                    if (t.isEmpty) return 'Isi kata sandi.';
                    if (!_isStrongPassword(t)) return 'Minimal 6 karakter.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Konfirmasi Kata Sandi
                const Text('Konfirmasi Kata Sandi'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: pass2Ctrl,
                  obscureText: obscure2,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => loading ? null : _onRegister(),
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi kata sandi Anda',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscure2 = !obscure2),
                    ),
                  ),
                  validator: (v) {
                    final t = v ?? '';
                    if (t.isEmpty) return 'Isi konfirmasi kata sandi.';
                    if (t != passCtrl.text) return 'Konfirmasi kata sandi tidak cocok.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Checkbox Syarat & Ketentuan
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      onChanged: (v) => setState(() => agree = v ?? false),
                      activeColor: green,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: const [
                            TextSpan(text: 'Saya menyetujui '),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Daftar', style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 12),
                // Link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Masuk', style: TextStyle(color: Colors.green)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
