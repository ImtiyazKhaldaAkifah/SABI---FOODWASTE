import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Backend rekomendasi resep (FastAPI buatan temanmu).
/// Alamat diatur lewat:  --dart-define=BACKEND_URL=http://192.168.x.x:8000
class BackendService {
  static const baseUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://127.0.0.1:8000');

  static Future<List<Recipe>> recommend(List<String> ingredientsEn, {int topN = 6}) async {
    final res = await http
        .post(Uri.parse('$baseUrl/recommend'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'ingredients': ingredientsEn, 'top_n': topN}))
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) throw Exception('Backend error ${res.statusCode}');
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    final list = (data['recommendations'] as List).cast<Map<String, dynamic>>();
    return [for (var i = 0; i < list.length; i++) _toRecipe(list[i], i)];
  }

  static String _title(String s) => s
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  static Recipe _toRecipe(Map<String, dynamic> j, int i) {
    final steps = (j['steps'] as List).map((e) {
      final t = '$e'.trim();
      return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
    }).toList();
    final matched = (j['matched_ingredients'] as List).map((e) => '$e').toList();
    final missing = (j['missing_ingredients'] as List).map((e) => '$e').toList();
    // Backend belum punya data tingkat kesulitan / durasi / porsi -> diperkirakan dari jumlah langkah.
    final n = steps.length;
    return Recipe(
      id: 'be_${DateTime.now().millisecondsSinceEpoch}_$i',
      title: _title('${j['name']}'),
      difficulty: n <= 5 ? 'Mudah' : (n <= 9 ? 'Sedang' : 'Sulit'),
      minutes: (n * 5).clamp(10, 120),
      servings: 2,
      ingredients: [for (final m in matched) Ingredient(m, ''), for (final m in missing) Ingredient(m, '')],
      steps: steps,
      tips: [if (missing.isNotEmpty) 'Bahan yang belum ada di stok: ${missing.join(', ')}'],
      isAi: true,
    );
  }
}
