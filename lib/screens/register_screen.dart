import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'shell.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _pass2Controller = TextEditingController();
  
  bool _agree = false;
  bool _obscureText1 = true;
  bool _obscureText2 = true;

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text;
    final pass2 = _pass2Controller.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data!')));
      return;
    }
    if (pass != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi kata sandi tidak sama!')));
      return;
    }
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setujui S&K SABI dulu ya!')));
      return;
    }

    final err = await AuthService.register(name, email, pass);
    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Shell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          // HAPUS SingleChildScrollView, ganti pakai Padding biasa
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            // Pakai Center biar kalau layarnya tinggi, isinya ada di tengah
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Biar seimbang di tengah
                children: [
                  // 🔴 BAGIAN LOGO DENGAN ANIMASI (UKURAN PAS) 🔴
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // Ukuran font SABI dari 80 jadi 60 aja biar muat
                        Text('SABÍ', style: ts(size: 60, w: FontWeight.w900, color: C.teal)),
                        Text('PANGAN TERJAGA, BUMI BAHAGIA!', style: ts(size: 12, w: FontWeight.w800)),
                        const SizedBox(height: 10),
                        
                        // Gambar keranjang pas, nggak kegedean
                        Image.asset(
                          'assets/images/fridge.png', 
                          height: 150, // <--- Ukuran pas buat 1 layar
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  // 🔴 AKHIR BAGIAN LOGO 🔴
                  
                  const SizedBox(height: 20),

                  // --- FORM NAMA ---
                  _buildTextField(_nameController, 'Nama Lengkap', false),
                  const SizedBox(height: 12),

                  // --- FORM EMAIL ---
                  _buildTextField(_emailController, 'Email / Nomor Handphone', false),
                  const SizedBox(height: 12),

                  // --- FORM PASSWORD ---
                  _buildTextField(_passController, 'Kata Sandi', _obscureText1, () {
                    setState(() => _obscureText1 = !_obscureText1);
                  }),
                  const SizedBox(height: 12),

                  // --- FORM KONFIRMASI PASSWORD ---
                  _buildTextField(_pass2Controller, 'Konfirmasi Kata Sandi', _obscureText2, () {
                    setState(() => _obscureText2 = !_obscureText2);
                  }),
                  const SizedBox(height: 12),

                  // --- CHECKBOX S&K ---
                  Row(
                    children: [
                      SizedBox(
                        height: 24, width: 24,
                        child: Checkbox(
                          value: _agree, 
                          activeColor: C.teal,
                          onChanged: (v) => setState(() => _agree = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Saya Menyetujui S&K Sabi', style: ts(size: 12, w: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- TOMBOL DAFTAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 50, // Tombol agak dipendekin dikit biar muat
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text('DAFTAR', style: ts(size: 15, w: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- LINK KE HALAMAN MASUK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah Punya Akun? ', style: ts(size: 12, w: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context, 
                            MaterialPageRoute(builder: (_) => const LoginScreen())
                          );
                        },
                        child: Text('Masuk', style: ts(size: 12, w: FontWeight.w900, color: C.teal)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget bantuan biar gak nulis kodingan kotak yang sama 4 kali
  Widget _buildTextField(TextEditingController controller, String hint, bool obscure, [VoidCallback? onToggle]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ts(size: 13, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          // Padding dalem kotak dikecilin biar gak makan tempat
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }
}