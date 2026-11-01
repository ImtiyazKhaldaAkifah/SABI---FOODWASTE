import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';
import '../models/models.dart';
import 'backend_service.dart';
import 'notification_service.dart';
import 'recipe_ai_service.dart';
import 'shelf_life.dart';
import 'translate_service.dart';

class AppState extends ChangeNotifier {
  /// Stok milik akun yang login (disimpan di tabel stock_items di Supabase).
  final List<FoodItem> items = [];
  String? syncError;

  /// Resep hanya berasal dari AI/backend (tombol "Buat resep dengan AI").
  final List<Recipe> recipes = [];

  final Set<String> favorites = {};
  bool aiLoading = false;
  String? aiError;
  bool notifOn = true;

  SupabaseClient get _db => Supabase.instance.client;

  Future<void> init() => load();

  /// Muat stok dari Supabase (dipanggil saat app dibuka dan setelah login).
  Future<void> load() async {
    syncError = null;
    if (!AppConfig.ready || _db.auth.currentUser == null) {
      items.clear();
      notifyListeners();
      return;
    }
    try {
      final rows = await _db.from('stock_items').select().order('expiry');
      items
        ..clear()
        ..addAll(rows.map(_fromRow));
      for (final f in items) {
        await NotificationService.scheduleExpiry(f);
      }
    } catch (e) {
      syncError = '$e';
      debugPrint('SABI load stok gagal: $e');
    }
    notifyListeners();
  }

  FoodItem _fromRow(Map<String, dynamic> r) => FoodItem(
        id: '${r['id']}',
        name: '${r['name']}',
        amount: (r['amount'] as num).toInt(),
        unit: '${r['unit']}',
        category: '${r['category']}',
        emoji: '${r['emoji']}',
        expiry: DateTime.parse('${r['expiry']}'),
      );

  List<FoodItem> get expiring => (items.where((e) => e.daysLeft <= 4).toList()..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)));

  Future<void> addItem(FoodItem f) async {
    var item = f;
    if (AppConfig.ready && _db.auth.currentUser != null) {
      try {
        final row = await _db.from('stock_items').insert({
          'name': f.name,
          'amount': f.amount,
          'unit': f.unit,
          'category': f.category,
          'emoji': f.emoji,
          'expiry': f.expiry.toIso8601String().substring(0, 10),
        }).select().single();
        item = _fromRow(row);
      } catch (e) {
        syncError = '$e';
        debugPrint('SABI simpan stok gagal: $e');
      }
    }
    items.add(item);
    notifyListeners();
    if (notifOn) await NotificationService.scheduleExpiry(item);
  }

  Future<void> removeItem(FoodItem f) async {
    items.remove(f);
    notifyListeners();
    await NotificationService.cancel(f);
    if (AppConfig.ready && _db.auth.currentUser != null) {
      try {
        await _db.from('stock_items').delete().eq('id', f.id);
      } catch (e) {
        debugPrint('SABI hapus stok gagal: $e');
      }
    }
  }

  bool _match(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();
    return a.contains(b) || b.contains(a);
  }

  /// Cari stok yang cocok dengan nama bahan (Indonesia ATAU Inggris dari backend).
  FoodItem? stockFor(String ingredient) {
    final ing = ingredient.toLowerCase();
    for (final s in items) {
      if (_match(s.name, ing)) return s;
      if (ShelfLife.toEnglish(s.name) == ing) return s;
    }
    return null;
  }

  int available(Recipe r) => r.ingredients.where((i) => stockFor(i.name) != null).length;

  void toggleFav(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    notifyListeners();
  }

  /// Rekomendasi resep: utamakan backend buatan tim, kalau gagal baru coba Gemini (kalau key ada).
  Future<void> generateAi({String? focus}) async {
    aiLoading = true;
    aiError = null;
    notifyListeners();
    try {
      final sorted = items.toList()..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
      final en = <String>{};
      for (final f in sorted) {
        final e = ShelfLife.toEnglish(f.name);
        if (e != null) en.add(e);
      }
      if (en.isEmpty) throw Exception('Belum ada bahan stok yang dikenali untuk dibuat resep');
      List<Recipe> r;
      try {
        r = await BackendService.recommend(en.toList());
        r = await TranslateService.translate(r); // Inggris -> Indonesia (aman: kalau gagal tetap Inggris)
      } catch (backendErr) {
        try {
          r = await RecipeAiService.generate(items, focus: focus);
        } catch (_) {
          throw Exception('Backend resep tidak terjangkau. Pastikan server jalan dan BACKEND_URL benar. ($backendErr)');
        }
      }
      recipes.removeWhere((x) => x.isAi);
      recipes.insertAll(0, r);
    } catch (e) {
      aiError = '$e';
    }
    aiLoading = false;
    notifyListeners();
  }
}