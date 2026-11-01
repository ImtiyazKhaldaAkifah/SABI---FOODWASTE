/// Data 58 label dari model + perkiraan masa simpan (hari).
/// Angka kulkas/ruangan adalah PERKIRAAN UMUM, silakan sesuaikan.
class ShelfInfo {
  final String name, category, emoji;
  final int fridge, room;
  final String? en; // nama Inggris untuk backend resep
  const ShelfInfo(this.name, this.category, this.emoji, this.fridge, this.room, [this.en]);
}

class ShelfLife {
  // key = label dari labels.txt (huruf kecil)
  static const _db = <String, ShelfInfo>{
    'kiwi': ShelfInfo('Kiwi', 'Buah', '🥝', 14, 5, 'kiwi'),
    'lemon': ShelfInfo('Lemon', 'Buah', '🍋', 21, 7, 'lemon'),
    'raspberry': ShelfInfo('Raspberry', 'Buah', '🍓', 5, 1, 'raspberry'),
    'adas': ShelfInfo('Adas', 'Bumbu', '🌿', 14, 7, 'fennel'),
    'anggur': ShelfInfo('Anggur', 'Buah', '🍇', 7, 2, 'grapes'),
    'apel': ShelfInfo('Apel', 'Buah', '🍎', 7, 4, 'apple'),
    'asam jawa': ShelfInfo('Asam Jawa', 'Bumbu', '🌿', 30, 14, 'tamarind'),
    'ayam mentah': ShelfInfo('Ayam Mentah', 'Protein', '🍗', 2, 0, 'chicken'),
    'bawang bombai': ShelfInfo('Bawang Bombai', 'Sayuran', '🧅', 30, 14, 'onion'),
    'bawang merah': ShelfInfo('Bawang Merah', 'Bumbu', '🧅', 30, 14, 'shallot'),
    'bawang putih': ShelfInfo('Bawang Putih', 'Bumbu', '🧄', 30, 14, 'garlic'),
    'bayam': ShelfInfo('Bayam', 'Sayuran', '🥬', 5, 1, 'spinach'),
    'biji kedelai': ShelfInfo('Biji Kedelai', 'Protein', '🫘', 7, 3, 'soybeans'),
    'bluberi': ShelfInfo('Bluberi', 'Buah', '🫐', 7, 1, 'blueberries'),
    'brokoli': ShelfInfo('Brokoli', 'Sayuran', '🥦', 5, 1, 'broccoli'),
    'buah naga': ShelfInfo('Buah Naga', 'Buah', '🍈', 7, 3, 'dragon fruit'),
    'cabai': ShelfInfo('Cabai', 'Bumbu', '🌶️', 7, 3, 'chili'),
    'daging sapi': ShelfInfo('Daging Sapi', 'Protein', '🥩', 3, 0, 'beef'),
    'delima': ShelfInfo('Delima', 'Buah', '🔴', 28, 7, 'pomegranate'),
    'gambas': ShelfInfo('Gambas', 'Sayuran', '🥒', 5, 2, 'luffa'),
    'ikan': ShelfInfo('Ikan', 'Protein', '🐟', 2, 0, 'fish'),
    'jagung': ShelfInfo('Jagung', 'Sayuran', '🌽', 3, 1, 'corn'),
    'jahe': ShelfInfo('Jahe', 'Bumbu', '🫚', 21, 7, 'ginger'),
    'jeruk': ShelfInfo('Jeruk', 'Buah', '🍊', 21, 7, 'orange'),
    'kacang polong': ShelfInfo('Kacang Polong', 'Sayuran', '🫛', 5, 1, 'peas'),
    'keju': ShelfInfo('Keju', 'Olahan Susu', '🧀', 14, 2, 'cheese'),
    'kelapa': ShelfInfo('Kelapa', 'Buah', '🥥', 7, 5, 'coconut'),
    'kembang kol': ShelfInfo('Kembang Kol', 'Sayuran', '🥦', 7, 2, 'cauliflower'),
    'kencur': ShelfInfo('Kencur', 'Bumbu', '🫚', 14, 5),
    'kentang': ShelfInfo('Kentang', 'Sayuran', '🥔', 30, 14, 'potato'),
    'kubis': ShelfInfo('Kubis', 'Sayuran', '🥬', 21, 5, 'cabbage'),
    'kunyit': ShelfInfo('Kunyit', 'Bumbu', '🫚', 21, 7, 'turmeric'),
    'labu': ShelfInfo('Labu', 'Sayuran', '🎃', 14, 7, 'pumpkin'),
    'lengkuas': ShelfInfo('Lengkuas', 'Bumbu', '🫚', 14, 5, 'galangal'),
    'lobak': ShelfInfo('Lobak', 'Sayuran', '🥕', 14, 4, 'radish'),
    'mangga': ShelfInfo('Mangga', 'Buah', '🥭', 7, 4, 'mango'),
    'melon': ShelfInfo('Melon', 'Buah', '🍈', 7, 4, 'melon'),
    'mentega': ShelfInfo('Mentega', 'Olahan Susu', '🧈', 60, 14, 'butter'),
    'nanas': ShelfInfo('Nanas', 'Buah', '🍍', 5, 2, 'pineapple'),
    'oyong': ShelfInfo('Oyong', 'Sayuran', '🥒', 5, 2, 'luffa'),
    'paprika': ShelfInfo('Paprika', 'Sayuran', '🫑', 10, 3, 'bell pepper'),
    'pare': ShelfInfo('Pare', 'Sayuran', '🥒', 5, 2, 'bitter melon'),
    'pir': ShelfInfo('Pir', 'Buah', '🍐', 7, 3, 'pear'),
    'pisang': ShelfInfo('Pisang', 'Buah', '🍌', 5, 3, 'banana'),
    'roti': ShelfInfo('Roti', 'Karbohidrat', '🍞', 5, 3, 'bread'),
    'seafood': ShelfInfo('Seafood', 'Protein', '🦐', 2, 0, 'shrimp'),
    'semangka': ShelfInfo('Semangka', 'Buah', '🍉', 7, 3, 'watermelon'),
    'sereh': ShelfInfo('Sereh', 'Bumbu', '🌿', 14, 5, 'lemongrass'),
    'stroberi': ShelfInfo('Stroberi', 'Buah', '🍓', 5, 1, 'strawberry'),
    'susu': ShelfInfo('Susu', 'Olahan Susu', '🥛', 7, 0, 'milk'),
    'tahu': ShelfInfo('Tahu', 'Protein', '🍢', 5, 1, 'tofu'),
    'tempe': ShelfInfo('Tempe', 'Protein', '🫘', 5, 2, 'tempeh'),
    'telor': ShelfInfo('Telur', 'Protein', '🥚', 21, 7, 'egg'),
    'terong': ShelfInfo('Terong', 'Sayuran', '🍆', 7, 3, 'eggplant'),
    'timun': ShelfInfo('Timun', 'Sayuran', '🥒', 7, 3, 'cucumber'),
    'tomat': ShelfInfo('Tomat', 'Sayuran', '🍅', 7, 3, 'tomato'),
    'ubi': ShelfInfo('Ubi', 'Karbohidrat', '🍠', 14, 7, 'sweet potato'),
    'wortel': ShelfInfo('Wortel', 'Sayuran', '🥕', 14, 4, 'carrot'),
  };

  static ShelfInfo lookup(String label) {
    final key = label.toLowerCase().trim();
    final exact = _db[key];
    if (exact != null) return exact;
    for (final e in _db.entries) {
      if (key.contains(e.key)) return e.value;
    }
    return ShelfInfo(label, 'Lain-lain', '🍽️', 5, 2);
  }

  /// Nama stok (Indonesia) -> nama Inggris untuk backend resep. null kalau tidak dikenal.
  static const _extra = <String, String>{
    'telur': 'egg', 'udang': 'shrimp', 'nasi': 'rice', 'ayam': 'chicken',
    'yoghurt': 'yogurt', 'yogurt': 'yogurt', 'tepung': 'flour', 'gula': 'sugar', 'garam': 'salt',
    'minyak': 'oil', 'cokelat': 'chocolate', 'coklat': 'chocolate', 'sawi': 'mustard greens',
    'bihun': 'rice noodles', 'mie': 'noodles', 'santan': 'coconut milk', 'madu': 'honey',
  };

  static String? toEnglish(String name) {
    final n = name.toLowerCase();
    final keys = <String, String>{
      for (final e in _db.entries)
        if (e.value.en != null) e.key: e.value.en!,
      ..._extra,
    };
    final sorted = keys.keys.toList()..sort((a, b) => b.length.compareTo(a.length)); // yang panjang dulu
    for (final k in sorted) {
      if (n.contains(k)) return keys[k];
    }
    return null;
  }
}
