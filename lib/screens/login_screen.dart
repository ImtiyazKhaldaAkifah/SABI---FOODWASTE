import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final id = TextEditingController(), pass = TextEditingController();

  Future<void> _login() async {
    final err = await AuthService.login(id.text.trim(), pass.text);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GradientBg(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(children: [
                  const Logo(size: 84),
                  Text('PANGAN TERJAGA, BUMI BAHAGIA!', style: ts(size: 13, w: FontWeight.w900)),
                  const SizedBox(height: 24),
                  const AssetImg('assets/images/fridge.png', fallback: '🧊', h: 170, fit: BoxFit.contain),
                  const SizedBox(height: 28),
                  SabiField(hint: 'Email / Nomor Handphone', controller: id),
                  SabiField(hint: 'Kata Sandi', controller: pass, password: true),
                  const SizedBox(height: 6),
                  SabiButton('MASUK', onTap: _login),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur lupa kata sandi: hubungkan ke backend'))),
                    child: Text('Lupa Kata Sandi?', style: ts(size: 12, w: FontWeight.w500).copyWith(decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Belum Punya Akun? ', style: ts(size: 12, w: FontWeight.w500)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: Text('Daftar', style: ts(size: 12, w: FontWeight.w500).copyWith(decoration: TextDecoration.underline)),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      );
}
