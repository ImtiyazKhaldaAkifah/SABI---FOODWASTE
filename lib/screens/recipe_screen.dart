import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart'; // Tambahan import model
import '../services/app_state.dart';
import 'recipe_detail_screen.dart'; // 🔴 TAMBAHAN IMPORT HALAMAN DETAIL

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String _selectedFilter = 'Semua Resep';

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Semua Resep', 'icon': Icons.menu_book},
    {'name': 'Favorit', 'icon': Icons.favorite},
    {'name': 'Pilih Bahan', 'icon': Icons.egg_alt},
    {'name': 'Tingkat Kesulitan', 'icon': Icons.bar_chart},
    {'name': 'Durasi Masak', 'icon': Icons.timer},
    {'name': 'Tipe Masakan', 'icon': Icons.restaurant},
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      backgroundColor: C.bgBottom,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  Text('REKOMENDASI', style: ts(size: 14, w: FontWeight.w700)),
                  Text('RESEP MASAKAN', style: ts(size: 24, w: FontWeight.w900)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      s.generateAi();
                    },
                    icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    label: Text('BUAT RESEP DENGAN AI', style: ts(size: 12, w: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                  ),
                  if (s.aiLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text('AI sedang memasak resep...', style: ts(size: 12, color: C.teal, w: FontWeight.w700)),
                    ),
                  if (s.aiError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(s.aiError!, style: ts(size: 12, color: Colors.red, w: FontWeight.w700), textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),

            // --- KONTEN UTAMA ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SIDEBAR KIRI
                      Container(
                        width: 90,
                        color: Colors.grey.shade50,
                        child: ListView.builder(
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final cat = _filters[index];
                            final isSelected = _selectedFilter == cat['name'];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = cat['name'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(
                                      color: isSelected ? C.teal : Colors.transparent,
                                      width: 4,
                                    ),
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      color: isSelected ? C.teal : Colors.grey.shade600,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat['name'].toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: ts(
                                        size: 10,
                                        w: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? Colors.black : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // DAFTAR RESEP KANAN
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: C.teal,
                              child: Center(
                                child: Text('RESEP TERSEDIA', style: ts(size: 14, w: FontWeight.w900, color: Colors.white)),
                              ),
                            ),
                            
                            Expanded(
                              child: s.recipes.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.restaurant_menu, size: 50, color: Colors.grey.shade300),
                                          const SizedBox(height: 12),
                                          Text('Belum ada resep', style: ts(size: 14, w: FontWeight.w700, color: Colors.grey.shade600)),
                                          const SizedBox(height: 4),
                                          Text('Klik tombol AI di atas\nuntuk membuat resep.', textAlign: TextAlign.center, style: ts(size: 10, color: Colors.grey)),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: s.recipes.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final recipe = s.recipes[index];
                                        return _buildRecipeCard(context, recipe);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔴 KARTU RESEP YANG BISA DIKLIK 🔴
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return InkWell( // Pakai InkWell biar ada efek riak air (ripple) pas diklik
      onTap: () {
        // Navigasi pindah ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: Image.network(
                'https://image.pollinations.ai/prompt/food%20photography%20of%20${Uri.encodeComponent(recipe.title)}?width=300&height=150&nologo=true',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.restaurant, size: 30, color: Colors.grey))),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: ts(size: 14, w: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${recipe.minutes} Menit', style: ts(size: 10, w: FontWeight.w600, color: Colors.grey.shade600)),
                      const SizedBox(width: 12),
                      Icon(Icons.bar_chart, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(recipe.difficulty, style: ts(size: 10, w: FontWeight.w600, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tombol Lihat Resep
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        // Pindah halaman juga kalau tombol ini yang diklik
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.teal.withOpacity(0.1),
                        foregroundColor: C.teal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('LIHAT RESEP', style: ts(size: 11, w: FontWeight.w800)),
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
}