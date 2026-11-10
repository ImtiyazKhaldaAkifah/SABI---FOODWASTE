import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Widget bantuan buat animasi berurutan
  Widget _buildAnimatedItem(int index, Widget child) {
    final start = (index * 0.1).clamp(0.0, 0.9);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final recipe = widget.recipe;
    final fav = s.favorites.contains(recipe.id);

    return Scaffold(
      backgroundColor: C.bgBottom,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER GAMBAR ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                  ),
                  // 🔴 BAGIAN GAMBAR YANG DIGANTI 🔴
                  child: Image.network(
                    'https://image.pollinations.ai/prompt/food%20photography%20of%20${Uri.encodeComponent(recipe.title)}?width=800&height=600&nologo=true',
                    fit: BoxFit.cover, // <--- INI KUNCI BIAR GAK PENYOK
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant, size: 80, color: Colors.white54),
                          const SizedBox(height: 10),
                          Text('Gambar tidak tersedia', style: ts(size: 14, color: Colors.white70, w: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tombol Back
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                // Tombol Love
                Positioned(
                  right: 16, top: 50,
                  child: GestureDetector(
                    onTap: () => s.toggleFav(recipe.id),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: C.red, size: 24),
                    ),
                  ),
                ),
                // Title Overlapping Image
                Positioned(
                  bottom: -30, left: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        Text(recipe.title.toUpperCase(), textAlign: TextAlign.center, style: ts(size: 18, w: FontWeight.w900)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statItem(Icons.timer, '${recipe.minutes} Menit', 'Waktu'),
                            Container(height: 30, width: 1, color: Colors.grey.shade300),
                            _statItem(Icons.restaurant, '${recipe.servings} Porsi', 'Sajian'),
                            Container(height: 30, width: 1, color: Colors.grey.shade300),
                            _statItem(Icons.bar_chart, recipe.difficulty, 'Kesulitan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50), 

            // --- KONTEN UTAMA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. CARD BAHAN-BAHAN
                  _buildAnimatedItem(0, 
                    _buildSectionCard(
                      title: 'Bahan-bahan',
                      icon: Icons.shopping_basket,
                      child: Column(
                        children: recipe.ingredients.map((ing) {
                          final st = s.stockFor(ing.name);
                          final hasStock = st != null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(hasStock ? Icons.check_circle : Icons.cancel, color: hasStock ? Colors.green : Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(ing.name, style: ts(size: 14, w: FontWeight.w700)),
                                ),
                                Text(ing.qty, style: ts(size: 14, w: FontWeight.w600, color: Colors.grey.shade600)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // 2. CARD CARA MEMASAK
                  _buildAnimatedItem(1, 
                    _buildSectionCard(
                      title: 'Cara Memasak',
                      icon: Icons.soup_kitchen,
                      child: Column(
                        children: List.generate(recipe.steps.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: C.teal.withOpacity(0.2),
                                  child: Text('${index + 1}', style: ts(size: 12, w: FontWeight.w900, color: C.teal)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(recipe.steps[index], style: ts(size: 14, w: FontWeight.w500).copyWith(height: 1.4)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // 3. CARD TIP AI
                  _buildAnimatedItem(2, 
                    _buildSectionCard(
                      title: 'Tip AI',
                      icon: Icons.lightbulb,
                      child: Column(
                        children: recipe.tips.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const SizedBox(width: 10),
                                Expanded(child: Text(tip, style: ts(size: 13, w: FontWeight.w600, color: Colors.grey.shade700))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: C.teal, size: 24),
              const SizedBox(width: 10),
              Text(title, style: ts(size: 16, w: FontWeight.w900)),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          child,
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: C.teal),
        const SizedBox(height: 4),
        Text(value, style: ts(size: 14, w: FontWeight.w900)),
        Text(label, style: ts(size: 10, w: FontWeight.w600, color: Colors.grey.shade600)),
      ],
    );
  }
}