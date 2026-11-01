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
  int tab = 0;
  static const tabs = ['SEMUA RESEP', 'FAVORIT', 'PILIH BAHAN', 'TINGKAT KESULITAN', 'DURASI MASAK', 'TIPE MASAKAN'];

  List<Recipe> _filtered(AppState s) {
    final l = s.recipes.toList();
    switch (tab) {
      case 1: return l.where((r) => s.favorites.contains(r.id)).toList();
      case 2: return l..sort((a, b) => s.available(b).compareTo(s.available(a)));
      case 3: return l..sort((a, b) => a.diffRank.compareTo(b.diffRank));
      case 4: return l..sort((a, b) => a.minutes.compareTo(b.minutes));
      case 5: return l..sort((a, b) => a.title.compareTo(b.title)); // TODO: tambah field tipe masakan
      default: return l;
    }
  }

  Color _dc(String d) => d == 'Mudah' ? C.teal : (d == 'Sedang' ? C.orange : C.red);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = _filtered(s);
    return GradientBg(
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 8),
          Text('REKOMENDASI', style: ts(size: 14, w: FontWeight.w900)),
          Text('RESEP MASAKAN', style: ts(size: 24, w: FontWeight.w900)),
          const SizedBox(height: 6),
          s.aiLoading
              ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 3))
              : Pill('✨ BUAT RESEP DENGAN AI DARI STOK', onTap: () async {
                  await s.generateAi();
                  if (context.mounted && s.aiError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${s.aiError}')));
                  }
                }),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.6), borderRadius: BorderRadius.circular(14), border: Border.all(color: C.teal.withOpacity(.5))),
              child: Row(children: [
                SizedBox(
                  width: 58,
                  child: ListView(children: [
                    for (var i = 0; i < tabs.length; i++)
                      GestureDetector(
                        onTap: () => setState(() => tab = i),
                        child: Container(
                          height: 50, alignment: Alignment.center, padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: tab == i ? C.teal.withOpacity(.75) : Colors.white, border: Border.all(color: Colors.black12)),
                          child: Text(tabs[i], textAlign: TextAlign.center, style: ts(size: 8, w: FontWeight.w900, color: tab == i ? Colors.white : Colors.black)),
                        ),
                      ),
                  ]),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(child: Text('Belum ada resep', style: ts()))
                      : ListView.builder(
                          padding: const EdgeInsets.all(6),
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final r = list[i];
                            final fav = s.favorites.contains(r.id);
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                const CircleAvatar(radius: 4, backgroundColor: C.teal),
                                const SizedBox(width: 6),
                                Expanded(child: Text(r.title, style: ts(size: 14, w: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                                if (r.isAi) Text('✨AI', style: ts(size: 10, color: C.teal)),
                              ]),
                              const SizedBox(height: 4),
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.teal.withOpacity(.6))),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(40), child: Padding(padding: const EdgeInsets.all(4), child: AssetImg(r.image, w: 78, h: 78))),
                                  Expanded(
                                    child: SizedBox(
                                      height: 92,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Expanded(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Text(r.difficulty.toUpperCase(), style: ts(size: 9, w: FontWeight.w900, color: _dc(r.difficulty))),
                                                Text('Estimasi: ${r.minutes} menit', style: ts(size: 8, w: FontWeight.w500)),
                                                Text('${r.servings} porsi orang dewasa', style: ts(size: 8, w: FontWeight.w500)),
                                                Text('${s.available(r)} dari ${r.ingredients.length} bahan tersedia di stok', style: ts(size: 8, w: FontWeight.w500)),
                                              ]),
                                            ),
                                            GestureDetector(
                                              onTap: () => s.toggleFav(r.id),
                                              child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: C.red, size: 20),
                                            ),
                                          ]),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))),
                                          child: Container(width: double.infinity, color: C.teal, padding: const EdgeInsets.symmetric(vertical: 6), alignment: Alignment.center,
                                              child: Text('LIHAT RESEP', style: ts(size: 10, w: FontWeight.w900, color: Colors.white))),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ]),
                              ),
                            ]);
                          },
                        ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
