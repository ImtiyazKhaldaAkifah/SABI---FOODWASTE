import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Jalankan app dengan:  flutter run --dart-define=GEMINI_API_KEY=xxxx
/// PENTING: untuk produksi, jangan taruh API key di app. Panggil lewat backend
/// (Firebase Cloud Functions / server sendiri) supaya key tidak bocor.
class RecipeAiService {
  static const _key = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = 'gemini-3.8-flash'; // cek nama model terbaru di dokumentasi Gemini

  static Future<List<Recipe>> generate(List<FoodItem> stock, {String? focus}) async {
    if (_key.isEmpty) throw Exception('GEMINI_API_KEY belum diisi');
    final stockText = (stock.toList()..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)))
        .map((e) => '${e.name} (${e.qty}, ${e.daysLeft} hari lagi kadaluarsa)')
        .join('; ');
    final prompt = '''
Kamu asisten masak untuk anak kos dan keluarga di Indonesia, tujuannya mengurangi food waste.
Stok bahan: $stockText.
${focus != null ? 'Fokus pada bahan: $focus.' : 'Prioritaskan bahan yang paling cepat kadaluarsa.'}
Buat 3 resep sederhana dan murah dalam Bahasa Indonesia.
Balas HANYA JSON array dengan format:
[{"title":"","difficulty":"Mudah|Sedang|Sulit","minutes":15,"servings":2,
"ingredients":[{"name":"","qty":""}],"steps":[""],"tips":[""]}]''';

    final res = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]}
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );
    if (res.statusCode != 200) throw Exception('AI error ${res.statusCode}');
    final text = jsonDecode(res.body)['candidates'][0]['content']['parts'][0]['text'] as String;
    final list = jsonDecode(text) as List;
    return [for (var i = 0; i < list.length; i++) Recipe.fromJson(list[i] as Map<String, dynamic>, i)];
  }
}
