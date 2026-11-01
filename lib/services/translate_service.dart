import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Menerjemahkan resep dari backend (Inggris) ke Bahasa Indonesia.
/// 1) Nama bahan  : pakai kamus offline di bawah (tanpa internet/key).
/// 2) Judul+langkah: lewat Gemini kalau GEMINI_API_KEY ada. Kalau gagal, tetap Inggris.
/// Jalankan app dengan:  --dart-define=GEMINI_API_KEY=KEY_KAMU
class TranslateService {
  static const _key = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = 'gemini-3.8-flash'; // samakan dengan model yang tersedia di AI Studio kamu

  static const _idNames = <String, String>{
    'egg': 'telur', 'eggs': 'telur', 'tomato': 'tomat', 'tomatoes': 'tomat', 'banana': 'pisang', 'milk': 'susu',
    'bread': 'roti', 'potato': 'kentang', 'potatoes': 'kentang', 'onion': 'bawang bombai', 'garlic': 'bawang putih',
    'shallot': 'bawang merah', 'carrot': 'wortel', 'broccoli': 'brokoli', 'spinach': 'bayam', 'cheese': 'keju',
    'butter': 'mentega', 'chicken': 'ayam', 'beef': 'daging sapi', 'fish': 'ikan', 'shrimp': 'udang', 'rice': 'nasi',
    'corn': 'jagung', 'apple': 'apel', 'orange': 'jeruk', 'lemon': 'lemon', 'cabbage': 'kubis', 'cucumber': 'timun',
    'eggplant': 'terong', 'pumpkin': 'labu', 'mango': 'mangga', 'pineapple': 'nanas', 'strawberry': 'stroberi',
    'tofu': 'tahu', 'tempeh': 'tempe', 'ginger': 'jahe', 'chili': 'cabai', 'flour': 'tepung', 'sugar': 'gula',
    'salt': 'garam', 'oil': 'minyak', 'chocolate': 'cokelat', 'yogurt': 'yoghurt', 'honey': 'madu', 'noodles': 'mie',
    'coconut milk': 'santan', 'lemongrass': 'sereh', 'turmeric': 'kunyit', 'galangal': 'lengkuas',
    'sweet potato': 'ubi', 'watermelon': 'semangka', 'pear': 'pir', 'grapes': 'anggur', 'pomegranate': 'delima',
    'coconut': 'kelapa', 'peas': 'kacang polong', 'cauliflower': 'kembang kol', 'radish': 'lobak',
    'bell pepper': 'paprika', 'bitter melon': 'pare', 'soybeans': 'kedelai', 'tamarind': 'asam jawa',
    'blueberries': 'bluberi', 'dragon fruit': 'buah naga', 'olive oil': 'minyak zaitun', 'black pepper': 'lada hitam',
    'pepper': 'lada', 'water': 'air', 'mushroom': 'jamur', 'sausage': 'sosis', 'cream': 'krim', 'cinnamon': 'kayu manis',
    'parsley': 'peterseli', 'vanilla': 'vanili', 'baking powder': 'baking powder', 'soy sauce': 'kecap asin',
  };

  static String _idName(String en) {
    final id = _idNames[en.toLowerCase().trim()] ?? en;
    return id.isEmpty ? id : id[0].toUpperCase() + id.substring(1);
  }

  static String _fixTip(String t) {
    const p = 'Bahan yang belum ada di stok: ';
    if (!t.startsWith(p)) return t;
    return p + t.substring(p.length).split(', ').map(_idName).join(', ');
  }

  static Recipe _copy(Recipe r, {String? title, List<String>? steps, List<Ingredient>? ingredients, List<String>? tips}) => Recipe(
        id: r.id,
        title: title ?? r.title,
        difficulty: r.difficulty,
        minutes: r.minutes,
        servings: r.servings,
        ingredients: ingredients ?? r.ingredients,
        steps: steps ?? r.steps,
        tips: tips ?? r.tips,
        image: r.image,
        isAi: r.isAi,
      );

  static Recipe _mapIngredients(Recipe r) => _copy(r,
      ingredients: [for (final i in r.ingredients) Ingredient(_idName(i.name), i.qty)],
      tips: r.tips.map(_fixTip).toList());

  /// Tidak pernah melempar error: kalau terjemahan gagal, hasil Inggris tetap dikembalikan.
  static Future<List<Recipe>> translate(List<Recipe> input) async {
    final base = input.map(_mapIngredients).toList();
    if (_key.isEmpty) {
      debugPrint('Terjemahan dilewati: GEMINI_API_KEY belum diisi');
      return base;
    }
    try {
      final payload = [for (final r in base) {'title': r.title, 'steps': r.steps}];
      final prompt = 'Terjemahkan judul dan langkah resep berikut ke Bahasa Indonesia yang natural dan mudah '
          'dipahami anak kos. Jangan mengubah jumlah dan urutan langkah. Pertahankan angka dan suhu. '
          'Balas HANYA JSON array dengan format yang sama: [{"title":"","steps":[""]}]. '
          'Data: ${jsonEncode(payload)}';
      final res = await http
          .post(
            Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent'),
            headers: {'Content-Type': 'application/json', 'x-goog-api-key': _key},
            body: jsonEncode({
              'contents': [
                {'parts': [{'text': prompt}]}
              ],
              'generationConfig': {'responseMimeType': 'application/json'},
            }),
          )
          .timeout(const Duration(seconds: 40));
      if (res.statusCode != 200) {
        debugPrint('Terjemahan gagal: HTTP ${res.statusCode} ${res.body}');
        return base;
      }
      final text = jsonDecode(utf8.decode(res.bodyBytes))['candidates'][0]['content']['parts'][0]['text'] as String;
      final list = jsonDecode(text) as List;
      if (list.length != base.length) return base;
      return [
        for (var i = 0; i < base.length; i++)
          _copy(base[i],
              title: '${list[i]['title']}',
              steps: (list[i]['steps'] as List).map((e) => '$e').toList()),
      ];
    } catch (e) {
      debugPrint('Terjemahan gagal: $e');
      return base;
    }
  }
}
