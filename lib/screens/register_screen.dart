import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController(), id = TextEditingController(), pass = TextEditingController(), pass2 = TextEditingController();
  bool agree = false;

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _register() async {
    if (name.text.trim().isEmpty || id.text.trim().isEmpty || pass.text.isEmpty) return _msg('Lengkapi semua data');
    if (pass.text != pass2.text) return _msg('Konfirmasi kata sandi tidak sama');
    if (!agree) return _msg('Setujui S&K Sabi dulu ya');
    final err = await AuthService.register(name.text.trim(), id.text.trim(), pass.text);
    if (!mounted) return;
    if (err != null) return _msg(err);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Shell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GradientBg(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(children: [
                  const AssetImg('assets/images/fridge.png', fallback: '🧊', h: 130, fit: BoxFit.contain),
                  const SizedBox(height: 18),
                  Text('BUAT AKUN BARU', style: ts(size: 16, w: FontWeight.w900)),
                  const SizedBox(height: 18),
                  SabiField(hint: 'Nama', controller: name),
                  SabiField(hint: 'Email / Nomor Handphone', controller: id),
                  SabiField(hint: 'Kata Sandi', controller: pass, password: true),
                  SabiField(hint: 'Konfirmasi Kata Sandi', controller: pass2, password: true),
                  Row(children: [
                    Checkbox(value: agree, onChanged: (v) => setState(() => agree = v ?? false), visualDensity: VisualDensity.compact),
                    Text('Saya Menyetujui S&K Sabi', style: ts(size: 11, w: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 10),
                  SabiButton('DAFTAR', onTap: _register),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Sudah Punya Akun? ', style: ts(size: 12, w: FontWeight.w500)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Masuk', style: ts(size: 12, w: FontWeight.w500).copyWith(decoration: TextDecoration.underline)),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      );
}
