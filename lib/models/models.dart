class FoodItem {
  final String id, name, unit, category, emoji;
  final int amount;
  final DateTime expiry;
  FoodItem({required this.id, required this.name, required this.amount, required this.unit, required this.category, required this.emoji, required this.expiry});

  int get daysLeft {
    final t = DateTime.now();
    final today = DateTime(t.year, t.month, t.day);
    return DateTime(expiry.year, expiry.month, expiry.day).difference(today).inDays;
  }

  String get qty => '$amount $unit';
}

class Ingredient {
  final String name, qty;
  Ingredient(this.name, this.qty);
}

class Recipe {
  final String id, title, difficulty; // Mudah / Sedang / Sulit
  final int minutes, servings;
  final List<Ingredient> ingredients;
  final List<String> steps, tips;
  final String? image;
  final bool isAi;
  Recipe({required this.id, required this.title, required this.difficulty, required this.minutes, required this.servings,
      required this.ingredients, required this.steps, required this.tips, this.image, this.isAi = false});

  int get diffRank => difficulty == 'Mudah' ? 0 : (difficulty == 'Sedang' ? 1 : 2);

  factory Recipe.fromJson(Map<String, dynamic> j, int i) => Recipe(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: j['title'] ?? 'Resep AI',
        difficulty: j['difficulty'] ?? 'Mudah',
        minutes: (j['minutes'] as num?)?.toInt() ?? 20,
        servings: (j['servings'] as num?)?.toInt() ?? 2,
        ingredients: ((j['ingredients'] ?? []) as List).map((e) => Ingredient('${e['name']}', '${e['qty'] ?? ''}')).toList(),
        steps: ((j['steps'] ?? []) as List).map((e) => '$e').toList(),
        tips: ((j['tips'] ?? []) as List).map((e) => '$e').toList(),
        isAi: true,
      );
}

const categories = ['Sayuran', 'Buah', 'Protein', 'Olahan Susu', 'Tepung', 'Karbohidrat', 'Bumbu', 'Lain-lain'];
