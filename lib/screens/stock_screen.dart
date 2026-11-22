import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class StockScreen extends StatefulWidget {
  final Function(int) onTab;
  const StockScreen({super.key, required this.onTab});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _selectedCategory = 'Semua Stok';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua Stok', 'emoji': '📦'},
    {'name': 'Sayuran', 'emoji': '🥦'},
    {'name': 'Buah', 'emoji': '🍎'},
    {'name': 'Protein', 'emoji': '🍗'},
    {'name': 'Olahan Susu', 'emoji': '🥛'},
    {'name': 'Tepung', 'emoji': '🌾'},
    {'name': 'Karbohidrat', 'emoji': '🍚'},
    {'name': 'Bumbu', 'emoji': '🧂'},
    {'name': 'Lain-lain', 'emoji': '🍽️'},
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    final filteredItems = s.items.where((item) {
      if (_selectedCategory == 'Semua Stok') return true;
      return item.category.toLowerCase() == _selectedCategory.toLowerCase();
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
                        widget.onTab(2); // Pindah ke tab Input
                      }),
                      const SizedBox(width: 12),
                      _actionButton('EDIT STOK', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ketuk langsung item di bawah untuk mengedit')));
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
                      // 1. SIDEBAR KIRI
                      Container(
                        width: 90,
                        color: Colors.grey.shade50,
                        child: ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
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
                                    Text(cat['emoji'], style: const TextStyle(fontSize: 28)),
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

                      // 2. DAFTAR STOK KANAN
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
                                        return InkWell(
                                          onTap: () => _showEditForm(context, item),
                                          child: _buildStockItem(item),
                                        );
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
                // 🔴 TAMBAHKAN BARIS INI BUAT NAMPILIN TANGGAL INPUT
                Text(
                  'Dibeli: ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}', 
                  style: ts(size: 10, color: Colors.grey.shade500),
                ),
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

  // 🔴 FORM POP-UP BUAT NGEDIT 🔴
  void _showEditForm(BuildContext context, FoodItem item) {
    final nameController = TextEditingController(text: item.name);
    final amountController = TextEditingController(text: item.amount.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Stok', style: ts(size: 18, w: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Makanan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Jumlah', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AppState>().removeItem(item);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: Text('Hapus', style: ts(color: Colors.red, w: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newName = nameController.text.trim();
                        final newAmount = int.tryParse(amountController.text) ?? item.amount;
                        
                        final updatedItem = FoodItem(
                          id: item.id,
                          name: newName,
                          amount: newAmount,
                          unit: item.unit,
                          category: item.category,
                          emoji: item.emoji,
                          expiry: item.expiry,
                          createdAt: item.createdAt, // 🔴 TAMBAHAN
                        );
                        
                        context.read<AppState>().updateItem(updatedItem);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok berhasil diupdate!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Simpan', style: ts(color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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