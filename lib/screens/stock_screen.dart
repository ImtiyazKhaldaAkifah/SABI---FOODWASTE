import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';

/// Form tambah stok manual (dipakai juga di halaman scan).
Future<void> showAddItemSheet(BuildContext context, {String? name, int days = 5}) {
  final n = TextEditingController(text: name ?? ''), amt = TextEditingController(text: '1'), unit = TextEditingController(text: 'Buah'), d = TextEditingController(text: '$days');
  String cat = categories.last;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('TAMBAH STOK', style: ts(size: 16, w: FontWeight.w900)),
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama makanan')),
          Row(children: [
            Expanded(child: TextField(controller: amt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Satuan'))),
          ]),
          TextField(controller: d, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kadaluarsa dalam (hari)')),
          DropdownButton<String>(isExpanded: true, value: cat, items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))], onChanged: (v) => set(() => cat = v!)),
          const SizedBox(height: 10),
          SabiButton('SIMPAN', onTap: () {
            if (n.text.trim().isEmpty) return;
            context.read<AppState>().addItem(FoodItem(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: n.text.trim(),
                  amount: int.tryParse(amt.text) ?? 1,
                  unit: unit.text,
                  category: cat,
                  emoji: '🍽️',
                  expiry: DateTime.now().add(Duration(days: int.tryParse(d.text) ?? 5)),
                ));
            Navigator.pop(ctx);
          }),
        ]),
      ),
    ),
  );
}

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  int cat = -1; // -1 = semua
  bool edit = false;

  static const icons = [Icons.eco_outlined, Icons.apple, Icons.kebab_dining, Icons.local_drink_outlined, Icons.inventory_2_outlined, Icons.bakery_dining_outlined, Icons.blender_outlined, Icons.grain];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.items.where((e) => cat == -1 || e.category == categories[cat]).toList()..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return GradientBg(
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 8),
          Text('DAFTAR', style: ts(size: 14, w: FontWeight.w900)),
          Text('STOK MAKANANKU', style: ts(size: 24, w: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Pill('TAMBAH STOK', onTap: () => showAddItemSheet(context)),
            const SizedBox(width: 10),
            Pill(edit ? 'SELESAI' : 'EDIT STOK', onTap: () => setState(() => edit = !edit)),
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.6), borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), border: Border.all(color: C.teal)),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Row(children: [
                  SizedBox(
                    width: 58,
                    child: Column(children: [
                      GestureDetector(
                        onTap: () => setState(() => cat = -1),
                        child: Container(height: 62, color: C.teal, alignment: Alignment.center,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.apps, color: Colors.white), Text('Semua Stok', style: ts(size: 8, color: Colors.white))])),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => setState(() => cat = i),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(color: cat == i ? C.teal.withOpacity(.2) : Colors.transparent, border: const Border(bottom: BorderSide(color: Colors.black26))),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icons[i], size: 24), Text(categories[i], style: ts(size: 8, w: FontWeight.w500))]),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Container(width: 1, color: C.teal),
                  Expanded(
                    child: Column(children: [
                      Container(height: 62, width: double.infinity, color: C.teal, alignment: Alignment.center, child: Text('STOK TERSEDIA', style: ts(size: 18, w: FontWeight.w900, color: Colors.white))),
                      Expanded(
                        child: list.isEmpty
                            ? Center(child: Text('Belum ada stok', style: ts()))
                            : ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (_, i) {
                                  final f = list[i];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
                                    child: Row(children: [
                                      Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF7FC8C4), borderRadius: BorderRadius.circular(6)), alignment: Alignment.center, child: Text(f.emoji, style: const TextStyle(fontSize: 22))),
                                      const SizedBox(width: 8),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(f.name, style: ts(size: 11, w: FontWeight.w900), overflow: TextOverflow.ellipsis),
                                        Text(f.qty, style: ts(size: 9, w: FontWeight.w500)),
                                      ])),
                                      if (edit)
                                        IconButton(icon: const Icon(Icons.delete_outline, color: C.red), onPressed: () => s.removeItem(f))
                                      else
                                        Column(children: [
                                          Text('${f.daysLeft < 0 ? 0 : f.daysLeft}', style: ts(size: 20, w: FontWeight.w900, color: daysColor(f.daysLeft))),
                                          Text('Hari Lagi', style: ts(size: 8, w: FontWeight.w800)),
                                        ]),
                                    ]),
                                  );
                                },
                              ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
