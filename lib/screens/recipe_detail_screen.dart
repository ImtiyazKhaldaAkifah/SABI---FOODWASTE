import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  Widget _title(String t) => Row(children: [
        const CircleAvatar(radius: 4, backgroundColor: C.teal),
        const SizedBox(width: 8),
        Text(t, style: ts(size: 14, w: FontWeight.w900)),
      ]);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final fav = s.favorites.contains(recipe.id);
    return Scaffold(
      body: GradientBg(
        child: Column(children: [
          Stack(children: [
            Container(color: Colors.black, height: 210, width: double.infinity, child: AssetImg(recipe.image, h: 210, fit: BoxFit.contain)),
            SafeArea(child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
            Positioned(
              left: 14, bottom: 12,
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: C.teal, borderRadius: BorderRadius.circular(20)),
                  child: Text(recipe.difficulty.toUpperCase(), style: ts(size: 11, w: FontWeight.w900, color: Colors.white))),
            ),
            Positioned(
              right: 14, bottom: 12,
              child: GestureDetector(
                onTap: () => s.toggleFav(recipe.id),
                child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: C.red, size: 20)),
              ),
            ),
          ]),
          Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(recipe.title.toUpperCase(), textAlign: TextAlign.center, style: ts(size: 18, w: FontWeight.w900))),
          Container(
            decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: C.teal.withOpacity(.6)))),
            child: Row(children: [
              for (final e in [('Estimasi Waktu Memasak:', '${recipe.minutes} Menit'), ('Prediksi Porsi:', '${recipe.servings} Porsi'), ('Kompleksitas', recipe.difficulty)])
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(border: Border(right: BorderSide(color: C.teal.withOpacity(.4)))),
                    child: Column(children: [Text(e.$1, style: ts(size: 8, w: FontWeight.w500)), Text(e.$2, style: ts(size: 16, w: FontWeight.w500))]),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(14), children: [
              _title('Bahan-bahan'),
              const SizedBox(height: 4),
              for (final ing in recipe.ingredients)
                Builder(builder: (_) {
                  final st = s.stockFor(ing.name);
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 2),
                    child: Row(children: [
                      Text(ing.name, style: ts(size: 12, w: FontWeight.w500)),
                      if (st != null) Text(' (${st.daysLeft} hari lagi)', style: ts(size: 12, color: daysColor(st.daysLeft)))
                      else Text(' (tidak ada di stok)', style: ts(size: 11, color: Colors.grey, w: FontWeight.w500)),
                      const Expanded(child: Divider(indent: 4, endIndent: 4, height: 1, color: Colors.black26)),
                      Text(ing.qty, style: ts(size: 12, w: FontWeight.w500)),
                    ]),
                  );
                }),
              const SizedBox(height: 14),
              _title('Cara Memasak'),
              for (var i = 0; i < recipe.steps.length; i++)
                Padding(padding: const EdgeInsets.only(left: 16, top: 3), child: Text('${i + 1}. ${recipe.steps[i]}', style: ts(size: 12, w: FontWeight.w500))),
              const SizedBox(height: 14),
              _title('Tip AI'),
              for (final t in recipe.tips) Padding(padding: const EdgeInsets.only(left: 16, top: 3), child: Text('• $t', style: ts(size: 12, w: FontWeight.w500))),
            ]),
          ),
        ]),
      ),
    );
  }
}
