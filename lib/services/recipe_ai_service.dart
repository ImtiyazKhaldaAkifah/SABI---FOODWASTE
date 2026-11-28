import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class RecipeAiService {
  // 🔑 Pastikan key ini BELUM PERNAH DI-RENAME di Google AI Studio
  static const _key = 'api key'; 
  
  // 🟢 Gunakan model yang valid
  static const _models = ['gemini-3.6-flash'];
  static const _cacheKey = 'cached_recipes';

  static Future<List<Recipe>> generate(List<FoodItem> stock, {String? focus}) async {
    if (_key.isEmpty || _key == 'MASUKKAN_KEY_BARU_DISINI') {
      throw Exception('API Key belum diisi atau masih teks bohongan!');
    }

    String prompt;
    if (focus != null && focus.isNotEmpty) {
      prompt = '''
User meminta resep dengan bahan utama: "$focus".
TUGAS UTAMA: Buat 3 resep sederhana dan murah yang menggunakan "$focus" sebagai bahan utama.
Balas HANYA JSON array dengan format:
[{"title":"","difficulty":"Mudah|Sedang|Sulit","minutes":15,"servings":2,
"ingredients":[{"name":"","qty":""}],"steps":[""],"tips":[""]}]''';
    } else {
      final stockText = (stock.toList()..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)))
          .map((e) => '${e.name} (${e.amount} ${e.unit}, ${e.daysLeft} hari lagi kadaluarsa)')
          .join('; ');
      prompt = '''
Stok bahan di kulkas: $stockText.
Prioritaskan bahan yang paling cepat kadaluarsa.
Buat 3 resep sederhana dan murah.
Balas HANYA JSON array dengan format:
[{"title":"","difficulty":"Mudah|Sedang|Sulit","minutes":15,"servings":2,
"ingredients":[{"name":"","qty":""}],"steps":[""],"tips":[""]}]''';
    }

    for (final model in _models) {
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');
          
          // 🟢 KUNCI: Kirim key HANYA lewat header x-goog-api-key
          final res = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _key,
            },
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': 'Kamu asisten masak anak kos. ATURAN MUTLAK: 1) WAJIB jawab HANYA pakai Bahasa Indonesia. 2) DILARANG KERAS pakai bahasa Inggris. 3) SELALU ikuti perintah user.'}
                ]
              },
              'contents': [{'parts': [{'text': prompt}]}],
              'generationConfig': {'responseMimeType': 'application/json'},
            }),
          ).timeout(const Duration(seconds: 30));

          if (res.statusCode == 200) {
            final text = jsonDecode(res.body)['candidates'][0]['content']['parts'][0]['text'] as String;
            final list = jsonDecode(text) as List;
            final recipes = [for (var i = 0; i < list.length; i++) Recipe.fromJson(list[i] as Map<String, dynamic>, i)];

            final prefs = await SharedPreferences.getInstance();
            final listJson = list.map((e) => jsonEncode(e)).toList(); 
            await prefs.setStringList(_cacheKey, listJson);

            return recipes;
          }
          
          if (res.statusCode == 503) {
            final waitTime = pow(2, attempt).toInt() + Random().nextInt(1000);
            print('Model $model sibuk (503). Menunggu ${waitTime}ms...');
            await Future.delayed(Duration(milliseconds: waitTime));
            continue; 
          }

          print('=== DETAIL ERROR DARI GOOGLE ===');
          print('Status: ${res.statusCode}');
          print('Body: ${res.body}');
          print('================================');
          throw Exception('API Google Error (Kode: ${res.statusCode}). Cek detail di terminal.');

        } catch (e) {
          print('Percobaan ke-${attempt + 1} untuk model $model gagal: $e');
          if (attempt == 1) break;
        }
      }
    }

    print('Semua model gagal. Mencoba mengambil dari cache lokal...');
    final prefs = await SharedPreferences.getInstance();
    final cachedList = prefs.getStringList(_cacheKey);

    if (cachedList != null && cachedList.isNotEmpty) {
      return [
        for (var i = 0; i < cachedList.length; i++) 
          Recipe.fromJson(jsonDecode(cachedList[i]), i)
      ];
    } else {
      throw Exception('Server AI sedang sibuk / API Key salah. Coba lagi nanti.');
    }
  }
}