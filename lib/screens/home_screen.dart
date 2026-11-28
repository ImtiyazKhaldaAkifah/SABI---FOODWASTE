import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // 🔴 Import buat WA
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import 'recipe_detail_screen.dart';
import 'faq_screen.dart'; // 🔴 Import halaman FAQ kamu
import '../main.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTab});
  final void Function(int) onTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  File? _profileImage;

  // 🔴 GANTI NOMOR INI DENGAN NOMOR WA ADMIN KAMU
  // Gunakan format 62 (tanpa tanda + atau 0 di depan)
  final String _adminWaNumber = '6282325875785'; 

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadProfileImage(); 
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (mounted) {
      setState(() {
        if (path != null && File(path).existsSync()) {
          _profileImage = File(path);
        } else {
          _profileImage = null;
        }
      });
    }
  }

  // 🔴 FUNGSI BARU: Buka WhatsApp
  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/62325975785?text=Halo%20Admin%20SABI,%20saya%20ingin%20memberi%20masukan.');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka WhatsApp.')),
        );
      }
    }
  }

  String _getEmojiForItem(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mangga')) return '🥭';
    if (lowerName.contains('apel')) return '🍎';
    if (lowerName.contains('kentang')) return '🥔';
    if (lowerName.contains('jagung')) return '🌽';
    if (lowerName.contains('ikan')) return '🐟';
    if (lowerName.contains('daging')) return '🥩';
    if (lowerName.contains('ayam')) return '🍗';
    if (lowerName.contains('telur')) return '🥚';
    if (lowerName.contains('susu')) return '🥛';
    if (lowerName.contains('sayur')) return '🥦';
    if (lowerName.contains('bayam')) return '🥬';
    if (lowerName.contains('wortel')) return '🥕';
    if (lowerName.contains('tomat')) return '🍅';
    if (lowerName.contains('bawang')) return '🧅';
    if (lowerName.contains('cabai')) return '🌶️';
    if (lowerName.contains('beras')) return '🍚';
    if (lowerName.contains('roti')) return '🍞';
    if (lowerName.contains('keju')) return '🧀';
    if (lowerName.contains('pisang')) return '🍌';
    if (lowerName.contains('jeruk')) return '🍊';
    return '🍽️'; 
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'] ?? 'Pengguna';
    final firstName = fullName.split(' ')[0];

    return Scaffold(
      backgroundColor: C.bgBottom,
      body: Stack(
        children: [
          Positioned.fill(child: GradientBg(child: const SizedBox.expand())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. HEADER DENGAN SAPAAN & AVATAR (SINKRON) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, $firstName! 👋', style: ts(size: 18, w: FontWeight.w900, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('Mau masak apa hari ini?', style: ts(size: 12, w: FontWeight.w600, color: Colors.grey.shade600)),
                        ],
                      ),
                      // Avatar Sinkron
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange.shade100),
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(_profileImage!, fit: BoxFit.cover, key: ValueKey(_profileImage!.path))
                              : Center(
                                  child: Text(
                                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                                    style: ts(size: 18, w: FontWeight.w900, color: C.teal),
                                  ),
                                ),
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

                  // --- 3. TOMBOL MENU (UDAH DISAMBUNGIN) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton('BERI MASUKAN', () {
                        // 🔴 BUKA WHATSAPP ADMIN
                        _openWhatsApp();
                      }),
                      _actionButton('FAQ', () {
                        // 🔴 PINDAH KE HALAMAN FAQ
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FaqScreen()),
                        );
                      }),
                      _actionButton('INPUT STOK', () => widget.onTab(2)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- 4. DAFTAR STOK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('DAFTAR STOK MAKANANKU', style: ts(size: 16, w: FontWeight.w900)),
                      GestureDetector(
                        onTap: () => widget.onTab(1),
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
                                Text(_getEmojiForItem(item.name), style: const TextStyle(fontSize: 40)),
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
                                Text(_getEmojiForItem(item.name), style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.daysLeft < 0
                                        ? '${item.name} (Kadaluarsa ${item.daysLeft.abs()} hari lalu)'
                                        : '${item.name} (${item.daysLeft} hari lagi)',
                                    style: ts(
                                      size: 13,
                                      w: FontWeight.w700,
                                      color: item.daysLeft < 0 ? Colors.red.shade900 : Colors.black87,
                                    ),
                                  ),
                                ),
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
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(_getFoodEmoji(recipe.title), style: const TextStyle(fontSize: 40)),
                                      ),
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
                      onPressed: () => widget.onTab(3), 
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

  String _getFoodEmoji(String title) {
    final t = title.toLowerCase();
    if (t.contains('ayam')) return '🍗';
    if (t.contains('ikan')) return '🐟';
    if (t.contains('daging') || t.contains('sapi')) return '🥩';
    if (t.contains('telur')) return '🥚';
    if (t.contains('sayur') || t.contains('kangkung') || t.contains('bayam')) return '🥬';
    if (t.contains('tahu') || t.contains('tempe')) return '🍢';
    if (t.contains('mie') || t.contains('nasi')) return '🍜';
    if (t.contains('kentang')) return '🥔';
    if (t.contains('sup') || t.contains('kuah')) return '🍲';
    return '🍲'; 
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