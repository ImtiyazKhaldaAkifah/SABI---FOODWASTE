import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _selectedCategory = 'Semua Stok';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua Stok', 'icon': Icons.grid_view_rounded},
    {'name': 'Sayuran', 'icon': Icons.eco},
    {'name': 'Buah', 'icon': Icons.local_florist},
    {'name': 'Protein', 'icon': Icons.egg_alt},
    {'name': 'Olahan Susu', 'icon': Icons.local_drink},
    {'name': 'Tepung', 'icon': Icons.rice_bowl},
    {'name': 'Karbohidrat', 'icon': Icons.bakery_dining},
    {'name': 'Bumbu', 'icon': Icons.spa},
    {'name': 'Lain-lain', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    final filteredItems = s.items.where((item) {
      if (_selectedCategory == 'Semua Stok') return true;
      return true; 
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
                  Text('DAFTAR', style: ts(size: 14, w: FontWeight.w700)),
                  Text('STOK MAKANANKU', style: ts(size: 24, w: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton('TAMBAH STOK', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buka halaman Tambah Stok')));
                      }),
                      const SizedBox(width: 12),
                      _actionButton('EDIT STOK', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mode Edit Stok aktif')));
                      }),
                    ],
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
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            
                            // 🔴 INI BAGIAN YANG TADI HILANG 🔴
                            final isSelected = _selectedCategory == cat['name'];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat['name'];
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
                                      cat['name'],
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

                      // DAFTAR STOK KANAN
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: C.teal,
                              child: Center(
                                child: Text('STOK TERSEDIA', style: ts(size: 14, w: FontWeight.w900, color: Colors.white)),
                              ),
                            ),
                            Expanded(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Text('Belum ada stok', style: ts(size: 14, color: Colors.grey)),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: filteredItems.length,
                                      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return _buildStockItem(item);
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

  Widget _buildStockItem(FoodItem item) {
    Color dayColor = Colors.green;
    if (item.daysLeft <= 2) {
      dayColor = Colors.red;
    } else if (item.daysLeft <= 5) {
      dayColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: ts(size: 14, w: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${item.amount} ${item.unit}', style: ts(size: 12, w: FontWeight.w500, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.daysLeft}', style: ts(size: 16, w: FontWeight.w900, color: dayColor)),
              Text('Hari Lagi', style: ts(size: 10, w: FontWeight.w600, color: dayColor)),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(text, style: ts(size: 12, w: FontWeight.w800, color: Colors.white)),
    );
  }
}