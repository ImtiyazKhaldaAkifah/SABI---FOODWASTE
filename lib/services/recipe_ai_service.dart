import 'dart:async'; 
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class RecipeAiService {
  static const _key = 'INI_KEY_RAHASIA';
  // 🔴 MODEL SUDAH DIPERBAIKI
  static const _models = ['gemini-3.6-flash', 'gemini-3.1-flash-lite']; 
  static const _cacheKey = 'cached_recipes';

  static Future<List<Recipe>> generate(List<FoodItem> stock, {String? focus}) async {
    if (_key.isEmpty) throw Exception('GEMINI_API_KEY belum diisi.');
    
    final stockText = (stock.toList()..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)))
        .map((e) => '${e.name} (${e.amount} ${e.unit}, ${e.daysLeft} hari lagi kadaluarsa)')
        .join('; ');
        
    final prompt = '''
Stok bahan: $stockText.
${focus != null ? 'Fokus pada bahan: $focus.' : 'Prioritaskan bahan yang paling cepat kadaluarsa.'}
Buat 3 resep sederhana dan murah.
Balas HANYA JSON array dengan format:
[{"title":"","difficulty":"Mudah|Sedang|Sulit","minutes":15,"servings":2,
"ingredients":[{"name":"","qty":""}],"steps":[""],"tips":[""]}]''';

    for (final model in _models) {
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final res = await http.post(
            Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent'),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _key,
            },
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': 'Kamu asisten masak anak kos. ATURAN MUTLAK: WAJIB jawab HANYA pakai Bahasa Indonesia. DILARANG KERAS pakai bahasa Inggris untuk isi teksnya (judul, bahan, langkah, tips).'}
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

          // Kalau error selain 503, kita print isi error dari Google biar tau masalahnya
          print('ERROR DARI GOOGLE: ${res.body}');
          throw Exception('API Google Error (Kode: ${res.statusCode}).');

        } on TimeoutException {
          print('Model $model timeout. Mencoba lagi...');
          if (attempt == 2) throw Exception('Koneksi lambat atau server Google tidak merespon (Timeout). Coba lagi ya!');
          
        } catch (e) {
          if (!e.toString().contains('503')) throw Exception(e.toString());
        }
      }
      print('Model $model gagal setelah 3 percobaan, beralih ke model lain...');
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
      throw Exception('Server AI sedang sibuk dan belum ada resep tersimpan. Coba lagi nanti.');
    }
  }
}