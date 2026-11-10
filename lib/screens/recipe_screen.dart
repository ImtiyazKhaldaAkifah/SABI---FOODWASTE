import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import 'recipe_detail_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String _selectedCategory = 'Semua Resep';
  String _selectedSubCategory = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Daftar menu di sidebar kiri
  final List<Map<String, dynamic>> _filters = [
    {'name': 'Semua Resep', 'icon': Icons.menu_book},
    {'name': 'Favorit', 'icon': Icons.favorite},
    {'name': 'Pilih Bahan', 'icon': Icons.egg_alt},
    {'name': 'Tingkat Kesulitan', 'icon': Icons.bar_chart},
    {'name': 'Durasi Masak', 'icon': Icons.timer},
    {'name': 'Tipe Masakan', 'icon': Icons.restaurant},
  ];

  // Daftar sub-filter yang muncul sesuai menu yang dipilih
  List<String> get _subFilters {
    switch (_selectedCategory) {
      case 'Pilih Bahan':
        return ['Semua', 'Sayuran', 'Protein', 'Karbohidrat', 'Buah', 'Bumbu'];
      case 'Tingkat Kesulitan':
        return ['Semua', 'Mudah', 'Sedang', 'Sulit'];
      case 'Durasi Masak':
        return ['Semua', '< 15 Menit', '15 - 30 Menit', '> 30 Menit'];
      case 'Tipe Masakan':
        return ['Semua', 'Goreng', 'Tumis', 'Rebus', 'Kukus'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    // 🔴 LOGIKA FILTER RESEP 🔴
    final filteredRecipes = s.recipes.where((recipe) {
      // 1. Filter berdasarkan Search Bar
      if (_searchQuery.isNotEmpty && !recipe.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // 2. Filter berdasarkan Sidebar Kiri
      if (_selectedCategory == 'Favorit') {
        if (!s.favorites.contains(recipe.id)) return false;
      } 
      else if (_selectedCategory == 'Tingkat Kesulitan') {
        if (_selectedSubCategory != 'Semua' && recipe.difficulty.toLowerCase() != _selectedSubCategory.toLowerCase()) return false;
      } 
      else if (_selectedCategory == 'Durasi Masak') {
        if (_selectedSubCategory == '< 15 Menit' && recipe.minutes >= 15) return false;
        if (_selectedSubCategory == '15 - 30 Menit' && (recipe.minutes < 15 || recipe.minutes > 30)) return false;
        if (_selectedSubCategory == '> 30 Menit' && recipe.minutes <= 30) return false;
      }
      else if (_selectedCategory == 'Pilih Bahan') {
        if (_selectedSubCategory != 'Semua') {
          final vegKeywords = ['sayur', 'wortel', 'bayam', 'kangkung', 'brokoli', 'tomat', 'bawang', 'cabai', 'timun', 'terong'];
          final proteinKeywords = ['ayam', 'sapi', 'telur', 'ikan', 'tahu', 'tempe', 'daging', 'udang'];
          
          bool match = false;
          for (var ing in recipe.ingredients) {
            String name = ing.name.toLowerCase();
            if (_selectedSubCategory == 'Sayuran' && vegKeywords.any((k) => name.contains(k))) { match = true; break; }
            if (_selectedSubCategory == 'Protein' && proteinKeywords.any((k) => name.contains(k))) { match = true; break; }
          }
          if (!match) return false;
        }
      }

      return true; // Lolos semua filter
    }).toList();

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
                    onPressed: () => s.generateAi(),
                    icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    label: Text('BUAT RESEP DENGAN AI', style: ts(size: 12, w: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. SIDEBAR KIRI
                      Container(
                        width: 90,
                        color: Colors.grey.shade50,
                        child: ListView.builder(
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final cat = _filters[index];
                            final isSelected = _selectedCategory == cat['name'];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat['name'];
                                  _selectedSubCategory = 'Semua'; // Reset sub-filter tiap ganti menu
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(color: isSelected ? C.teal : Colors.transparent, width: 4),
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(cat['icon'] as IconData, color: isSelected ? C.teal : Colors.grey.shade600, size: 24),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat['name'].toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: ts(size: 10, w: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? Colors.black : Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 2. AREA KONTEN (SEARCH & LIST RESEP)
                      Expanded(
                        child: Column(
                          children: [
                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(() => _searchQuery = val),
                                decoration: InputDecoration(
                                  hintText: 'Cari resep...',
                                  hintStyle: ts(size: 12, color: Colors.grey),
                                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                ),
                              ),
                            ),

                            // Sub-Filter (Muncul kalau pilih menu selain 'Semua Resep')
                            if (_subFilters.isNotEmpty)
                              SizedBox(
                                height: 40,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  itemCount: _subFilters.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final sub = _subFilters[index];
                                    final isSubSelected = _selectedSubCategory == sub;
                                    return ChoiceChip(
                                      label: Text(sub, style: ts(size: 10, w: FontWeight.w700, color: isSubSelected ? Colors.white : Colors.black87)),
                                      selected: isSubSelected,
                                      selectedColor: C.teal,
                                      backgroundColor: Colors.grey.shade200,
                                      onSelected: (val) {
                                        setState(() => _selectedSubCategory = sub);
                                      },
                                    );
                                  },
                                ),
                              ),

                            // 🔴 LIST RESEP (YANG UDAH DIBENERIN) 🔴
                            Expanded(
                              child: filteredRecipes.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // 1. KALAU LAGI LOADING
                                            if (s.aiLoading) ...[
                                              const CircularProgressIndicator(color: C.teal),
                                              const SizedBox(height: 16),
                                              Text('AI sedang memasak resep...', style: ts(size: 14, w: FontWeight.w700, color: C.teal)),
                                            ] 
                                            // 2. KALAU ADA ERROR
                                            else if (s.aiError != null) ...[
                                              Icon(Icons.error_outline, size: 50, color: Colors.red.shade300),
                                              const SizedBox(height: 12),
                                              Text(s.aiError!, textAlign: TextAlign.center, style: ts(size: 14, w: FontWeight.w700, color: Colors.red)),
                                            ] 
                                            // 3. KALAU BELUM ADA DATA SAMA SEKALI
                                            else ...[
                                              Icon(Icons.restaurant_menu, size: 50, color: Colors.grey.shade300),
                                              const SizedBox(height: 12),
                                              Text('Belum ada resep nih.', style: ts(size: 14, w: FontWeight.w700, color: Colors.grey.shade600)),
                                              const SizedBox(height: 4),
                                              Text('Klik tombol "BUAT RESEP DENGAN AI" di atas ya!', textAlign: TextAlign.center, style: ts(size: 12, color: Colors.grey.shade500)),
                                            ]
                                          ],
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: filteredRecipes.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final recipe = filteredRecipes[index];
                                        return _buildRecipeCard(context, recipe, s);
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

  // 🔴 DESAIN KARTU RESEP (SESUAI GAMBAR) 🔴
  Widget _buildRecipeCard(BuildContext context, Recipe recipe, AppState s) {
    // Hitung bahan yang nggak ada di stok (buat ditampilin di card)
    int missingCount = 0;
    for (var ing in recipe.ingredients) {
      if (s.stockFor(ing.name) == null) missingCount++;
    }

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Makanan
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://image.pollinations.ai/prompt/food%20photography%20of%20${Uri.encodeComponent(recipe.title)}?width=150&height=150&nologo=true',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: Colors.grey.shade200, child: const Icon(Icons.restaurant)),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info Resep
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: ts(size: 14, w: FontWeight.w900), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  
                  // Badge Waktu & Kesulitan
                  Row(
                    children: [
                      Icon(Icons.timer, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${recipe.minutes} Menit', style: ts(size: 10, w: FontWeight.w600, color: Colors.grey.shade600)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(recipe.difficulty, style: ts(size: 9, w: FontWeight.w800, color: Colors.green.shade800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Info Bahan Kurang
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 12, color: missingCount > 0 ? Colors.red : Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        missingCount > 0 ? '$missingCount bahan tidak ditemukan' : 'Semua bahan tersedia',
                        style: ts(size: 10, w: FontWeight.w600, color: missingCount > 0 ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Tombol Lihat Resep
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      child: Text('LIHAT RESEP', style: ts(size: 10, w: FontWeight.w800, color: Colors.white)),
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