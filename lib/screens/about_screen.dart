import 'package:flutter/material.dart';
import '../core/theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
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
        title: Text('Tentang Aplikasi', style: ts(size: 18, w: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. LOGO & TAGLINE
            _buildAnimatedItem(0, 
              Column(
                children: [
                  const SizedBox(height: 10),
                  Text('SABÍ', style: ts(size: 70, w: FontWeight.w900, color: C.teal)),
                  Text('PANGAN TERJAGA, BUMI BAHAGIA!', style: ts(size: 13, w: FontWeight.w800)),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 2. APA ITU SABI?
            _buildAnimatedItem(1, 
              _infoCard(
                icon: Icons.eco,
                title: 'Apa itu SABI?',
                content: 'SABI adalah aplikasi pintar berbasis AI yang dirancang khusus untuk membantu mengurangi limbah makanan (food waste) di rumah tangga dan anak kos. Kami percaya bahwa makanan layak diselamatkan, bukan dibuang.',
              ),
            ),

            // 3. KENAPA SABI DIBUAT?
            _buildAnimatedItem(2, 
              _infoCard(
                icon: Icons.track_changes,
                title: 'Kenapa SABI Dibuat?',
                content: 'Banyak dari kita sering membeli bahan makanan tapi lupa akan kadaluarsa, berujung terbuang sia-sia. SABI hadir sebagai asisten dapur digital yang membantu kamu memantau stok, memberikan notifikasi, dan meracik resep lezat dari sisa bahan yang ada. Hemat uang, selamatkan bumi!',
              ),
            ),

            // 4. INFORMASI VERSI & DEVELOPER
            _buildAnimatedItem(3, 
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Versi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: C.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Versi 1.0.0', style: ts(size: 14, w: FontWeight.w900, color: C.teal)),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 20),
                    
                    // Developer
                    Text('Dikembangkan dengan sepenuh hati ❤️', style: ts(size: 13, w: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text('Oleh: TIMSES SABI', style: ts(size: 16, w: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('2026', style: ts(size: 12, w: FontWeight.w600, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget bantuan buat bikin card/kotak penjelasan
  Widget _infoCard({required IconData icon, required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: C.teal, size: 24),
              const SizedBox(width: 12),
              Text(title, style: ts(size: 16, w: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content, 
            style: ts(size: 13, color: Colors.grey.shade700, w: FontWeight.w500).copyWith(height: 1.5), // Line height biar enak dibaca
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}