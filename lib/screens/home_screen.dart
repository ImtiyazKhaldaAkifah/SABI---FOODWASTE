import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import 'recipe_detail_screen.dart';
import 'stock_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onTab;
  const HomeScreen({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return GradientBg(
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
          const Center(child: Logo(size: 56)),
          Center(child: Text('PANGAN TERJAGA, BUMI BAHAGIA!', style: ts(size: 11, w: FontWeight.w900))),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8, offset: const Offset(2, 4))]),
            child: TextField(
              style: ts(size: 13),
              decoration: InputDecoration(
                  hintText: 'cari stok atau resep ...', hintStyle: ts(size: 12, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 18), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Pill('BERI MASUKAN', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih! (hubungkan ke form feedback)')))),
            const SizedBox(width: 10),
            Pill('FAQ', onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('FAQ'), content: const Text('Isi FAQ di sini.')))),
            const SizedBox(width: 10),
            Pill('INPUT STOK', onTap: () => onTab(2)),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('DAFTAR STOK MAKANANKU', style: ts(size: 12, w: FontWeight.w900)),
            GestureDetector(onTap: () => onTab(1), child: Text('Lihat Semua', style: ts(size: 10, color: C.teal, w: FontWeight.w800))),
          ]),
          const SizedBox(height: 6),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: s.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, n) {
                final f = s.items[n];
                return Container(
                  width: 54,
                  decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(f.emoji, style: const TextStyle(fontSize: 26)),
                    Text(f.name.split(' ').first, style: ts(size: 10), overflow: TextOverflow.ellipsis),
                    Text(f.qty.toLowerCase(), style: ts(size: 8, w: FontWeight.w500)),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          if (s.expiring.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFFE9E9), borderRadius: BorderRadius.circular(8), border: Border.all(color: C.red.withOpacity(.5))),
              child: Column(children: [
                Text('⚠️ PERINGATAN KADALUARSA ⚠️', style: ts(size: 11, w: FontWeight.w900)),
                const SizedBox(height: 4),
                for (final f in s.expiring.take(3))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Text(f.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(f.name, style: ts(size: 12, w: FontWeight.w500)),
                      Text(' (${f.daysLeft} hari lagi)', style: ts(size: 12, color: C.red)),
                      const Expanded(child: Divider(indent: 4, endIndent: 4, height: 1, color: Colors.black26)),
                      Text(f.qty, style: ts(size: 12, w: FontWeight.w500)),
                    ]),
                  ),
              ]),
            ),
          const SizedBox(height: 14),
          Center(child: Text('REKOMENDASI RESEP DARI STOK', style: ts(size: 12, w: FontWeight.w900))),
          const SizedBox(height: 6),
          Row(children: [
            for (final r in s.recipes.take(3))
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: C.teal.withOpacity(.4))),
                    child: Column(children: [
                      Container(
                        color: C.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(r.difficulty.toUpperCase(), style: ts(size: 7, color: Colors.white, w: FontWeight.w900)),
                          Text('${r.minutes} menit', style: ts(size: 7, color: Colors.white, w: FontWeight.w500)),
                        ]),
                      ),
                      Padding(padding: const EdgeInsets.all(5), child: ClipOval(child: AssetImg(r.image, w: 60, h: 60))),
                      Text(r.title, style: ts(size: 10, w: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Container(
                        margin: const EdgeInsets.fromLTRB(6, 3, 6, 6),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: C.teal)),
                        child: Text('lihat resep', style: ts(size: 8, color: C.teal, w: FontWeight.w800)),
                      ),
                    ]),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 6),
          Center(
            child: GestureDetector(
              onTap: () => onTab(3),
              child: Text('lihat resep lainnya', style: ts(size: 9, w: FontWeight.w500).copyWith(decoration: TextDecoration.underline)),
            ),
          ),
        ]),
      ),
    );
  }
}
