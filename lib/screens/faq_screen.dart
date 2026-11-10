import 'package:flutter/material.dart';
import '../core/theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        title: Text('FAQ', style: ts(size: 18, w: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Banner Penjelasan API Key
            _buildAnimatedItem(0, 
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.vpn_key, color: C.teal, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apa itu API Key Gemini?', style: ts(size: 14, w: FontWeight.w900, color: C.teal)),
                          const SizedBox(height: 4),
                          Text('API Key adalah "kunci VIP" aplikasi SABI agar bisa terhubung dengan otak AI Google Gemini untuk membuat resep masakan.', style: ts(size: 12, color: Colors.grey.shade800, w: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List FAQ
            _buildAnimatedItem(1, _faqTile(
              'Kenapa resep AI tidak muncul?',
              'Pastikan HP kamu terhubung ke internet dan kuota API Key Gemini masih tersedia. Jika server Google sedang sibuk, coba klik "Buat Resep" lagi beberapa saat kemudian.',
            )),
            _buildAnimatedItem(2, _faqTile(
              'Apakah aplikasi bisa digunakan offline?',
              'Bisa! Fitur input stok dan melihat resep yang sudah pernah dibuat tetap berjalan offline. Namun, untuk membuat resep BARU dengan AI, kamu membutuhkan koneksi internet.',
            )),
            _buildAnimatedItem(3, _faqTile(
              'Apakah data stok saya aman?',
              'Sangat aman. Data stok dan akun kamu disimpan secara terenkripsi di database Supabase, dan hanya bisa diakses oleh akunmu sendiri.',
            )),
            _buildAnimatedItem(4, _faqTile(
              'Kenapa gambar resepnya aneh/kurang cocok?',
              'Gambar dibuat otomatis oleh AI berdasarkan judul resep. Kadang hasilnya bisa sedikit acak atau tidak persis seperti aslinya. Kamu bisa mengabaikan gambarnya dan fokus pada teks resepnya.',
            )),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        title: Text(question, style: ts(size: 14, w: FontWeight.w800)),
        iconColor: C.teal,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: ts(size: 13, color: Colors.grey.shade700, w: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}