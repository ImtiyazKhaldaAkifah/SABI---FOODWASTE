import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscureText = true;

  void _login() async {
    final email = _emailController.text.trim();
    final pass = _passController.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email dan password wajib diisi!')));
      return;
    }

    final err = await AuthService.login(email, pass);
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // 🔴 BAGIAN LOGO DENGAN ANIMASI 🔴
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
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
                        Text('SABÍ', style: ts(size: 80, w: FontWeight.w900, color: C.teal)),
                        Text('PANGAN TERJAGA, BUMI BAHAGIA!', style: ts(size: 14, w: FontWeight.w800)),
                        const SizedBox(height: 30),
                        
                        // 🔴 GAMBAR KERANJANGNYA DIGEDEIN DI SINI 🔴
                        Image.asset(
                          'assets/images/fridge.png', 
                          height: 250, // <--- Udah aku gedein jadi 250
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  // 🔴 AKHIR BAGIAN LOGO 🔴
                  
                  const SizedBox(height: 40),

                  // --- FORM EMAIL ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email / Nomor Handphone',
                        hintStyle: ts(size: 14, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- FORM PASSWORD ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Kata Sandi',
                        hintStyle: ts(size: 14, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL MASUK ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text('MASUK', style: ts(size: 16, w: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- LUPA PASSWORD & DAFTAR ---
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Lupa Kata Sandi belum tersedia.')));
                    },
                    child: Text('Lupa Kata Sandi?', style: ts(size: 13, w: FontWeight.w600, color: C.teal)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum Punya Akun? ', style: ts(size: 13, w: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                        },
                        child: Text('Daftar', style: ts(size: 13, w: FontWeight.w900, color: C.teal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}