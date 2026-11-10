import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 🔴 TAMBAHAN IMPORT UNTUK WA
import '../core/theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    final start = (index * 0.15).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bgBottom,
      appBar: AppBar(
        title: Text('Bantuan', style: ts(size: 18, w: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAnimatedItem(0, _helpItem('1. Cara Menambah Stok', 'Kamu bisa menekan tombol "Input Stok" di Beranda atau menu "Input" di bawah untuk scan barcode/makanan lewat kamera, atau input manual dengan mengetik namanya.')),
            
            _buildAnimatedItem(1, _helpItem('2. Melihat Peringatan Kadaluarsa', 'Stok makanan yang mendekati tanggal kadaluarsa (H-3) akan otomatis muncul di kotak merah pada halaman Beranda. Pastikan notifikasi HP menyala ya!')),
            
            _buildAnimatedItem(2, _helpItem('3. Membuat Resep AI', 'Buka menu "Resep" di pojok kanan bawah, lalu tekan tombol "Buat Resep dengan AI". Tunggu beberapa saat, AI akan membuatkan resep berdasarkan sisa bahanmu.')),
            
            _buildAnimatedItem(3, _helpItem('4. Mengganti Nama Profil', 'Buka menu "Profil", pilih "Pengaturan Akun", lalu ubah namamu dan klik Simpan.')),
            
            const SizedBox(height: 10),

            // 🔴 TOMBOL KONTAK ADMIN YANG UDAH BISA KE WA 🔴
            _buildAnimatedItem(4, 
              Column(
                children: [
                  Text('Masih butuh bantuan?', style: ts(size: 14, w: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // ⚠️ GANTI NOMOR DI BAWAH INI DENGAN NOMOR WA KAMU
                      // Pakai awalan 62, tanpa tanda + atau 0. Contoh: 6281234567890
                      final String phone = '6282325875785'; 
                      final String message = 'Halo Admin SABI, saya butuh bantuan terkait aplikasi.';
                      
                      // Link sakti buat buka WA otomatis
                      final Uri url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                      
                      // Coba buka WhatsApp
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal membuka WhatsApp. Pastikan aplikasi WA terinstall.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat, color: Colors.white, size: 18), // Ganti ikon jadi chat
                    label: Text('Hubungi Admin', style: ts(color: Colors.white, w: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpItem(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ts(size: 15, w: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(desc, style: ts(size: 13, color: Colors.grey.shade700, w: FontWeight.w500)),
        ],
      ),
    );
  }
}