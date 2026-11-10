import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTab});

  final void Function(int) onTab;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    // Ambil nama user dari database
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? 'Pengguna';
    final firstName = fullName.split(' ')[0]; // Ambil nama depan aja

    return Scaffold(
      backgroundColor: C.bgBottom,
      body: Stack(
        children: [
          Positioned.fill(
            child: GradientBg(child: const SizedBox.expand()),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. HEADER DENGAN SAPAAN (RATA KIRI & AVATAR) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $firstName! 👋', 
                            style: ts(size: 18, w: FontWeight.w900, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mau masak apa hari ini?',
                            style: ts(size: 12, w: FontWeight.w600, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      // Avatar Inisial Nama
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: C.teal,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                          style: ts(size: 18, w: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // --- LOGO SABI DI TENGAH ---
                  Center(
                    child: Column(
                      children: [
                        Text('SABÍ', style: ts(size: 50, w: FontWeight.w900, color: C.teal)),
                        Text('PANGAN TERJAGA, BUMI BAHAGIA!', style: ts(size: 12, w: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 2. SEARCH BAR ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15)],
                    ),
                    child: TextField(
                      style: ts(size: 15),
                      decoration: InputDecoration(
                        hintText: 'cari stok atau resep ...',
                        hintStyle: ts(size: 15, w: FontWeight.w500, color: Colors.grey),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.grey, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 3. TOMBOL MENU ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton('BERI MASUKAN', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Beri Masukan segera hadir!')));
                      }),
                      _actionButton('FAQ', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur FAQ segera hadir!')));
                      }),
                      _actionButton('INPUT STOK', () => onTab(2)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- 4. DAFTAR STOK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('DAFTAR STOK MAKANANKU', style: ts(size: 16, w: FontWeight.w900)),
                      GestureDetector(
                        onTap: () => onTab(1),
                        child: Text('Lihat Semua', style: ts(size: 14, w: FontWeight.w700, color: C.teal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (s.items.isEmpty)
                    _emptyStateBox('Belum ada stok. Yuk, isi dulu!', Icons.inventory_2_outlined, 140)
                  else
                    SizedBox(
                      height: 140, 
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: s.items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = s.items[index];
                          return Container(
                            width: 100, 
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text(item.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(size: 13, w: FontWeight.w800)),
                                Text('${item.amount} ${item.unit}', style: ts(size: 12, color: Colors.grey.shade600, w: FontWeight.w600)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),

                  // --- 5. PERINGATAN KADALUARSA ---
                  if (s.expiring.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: 6),
                              Text('PERINGATAN KADALUARSA', style: ts(size: 14, w: FontWeight.w900, color: Colors.red.shade900)),
                              const SizedBox(width: 6),
                              const Icon(Icons.warning, color: Colors.orange, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...s.expiring.take(3).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(child: Text('${item.name} (${item.daysLeft} hari lagi)', style: ts(size: 13, w: FontWeight.w700))),
                                Text('${item.amount} ${item.unit}', style: ts(size: 13, w: FontWeight.w900)),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),

                  // --- 6. REKOMENDASI RESEP ---
                  Center(child: Text('REKOMENDASI RESEP DARI STOK', style: ts(size: 16, w: FontWeight.w900))),
                  const SizedBox(height: 12),
                  
                  if (s.recipes.isEmpty)
                    _emptyStateBox('Belum ada resep. Klik "Buat Resep".', Icons.restaurant_menu, 160)
                  else
                    SizedBox(
                      height: 220, 
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: s.recipes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final recipe = s.recipes[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                            child: Container(
                              width: 180, 
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: C.teal,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(recipe.difficulty.toUpperCase(), style: ts(size: 11, w: FontWeight.w900, color: Colors.white)),
                                        Text('${recipe.minutes} mnt', style: ts(size: 11, w: FontWeight.w600, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Image.network(
                                      'https://image.pollinations.ai/prompt/food%20photography%20of%20${Uri.encodeComponent(recipe.title)}?width=300&height=200&nologo=true',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.restaurant, color: Colors.grey, size: 40)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      recipe.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: ts(size: 14, w: FontWeight.w800),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: C.teal, width: 1.5),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Center(child: Text('lihat resep', style: ts(size: 12, color: C.teal, w: FontWeight.w900))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Center(
                    child: TextButton(
                      onPressed: () => onTab(3), 
                      child: Text('lihat resep lainnya', style: ts(size: 14, color: Colors.grey.shade800, w: FontWeight.w700).copyWith(decoration: TextDecoration.underline)),
                    ),
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: C.teal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(text, style: ts(size: 13, w: FontWeight.w900, color: Colors.white)),
    );
  }

  Widget _emptyStateBox(String text, IconData icon, double height) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.grey.shade400), 
          const SizedBox(height: 12),
          Text(text, style: ts(size: 14, color: Colors.grey.shade700, w: FontWeight.w700)),
        ],
      ),
    );
  }
}