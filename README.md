# SABI: Pangan Terjaga, Bumi Bahagia

Aplikasi mobile (Flutter) untuk mengurangi food waste rumah tangga. Pengguna mencatat bahan makanan, mendapat pengingat sebelum kadaluarsa, dan menerima saran resep dari bahan yang sudah ada.

> Status: dalam pengembangan.

## Fitur
- **Scan bahan** lewat kamera. Model MobileNetV2 (TFLite, 59 kelas) berjalan di dalam app.
- **Stok makanan** dengan perkiraan masa simpan dan tanggal kadaluarsa, tersimpan per akun.
- **Notifikasi** pengingat kadaluarsa (H-3).
- **Rekomendasi resep** dari bahan di stok, lewat backend FastAPI.
- **Login dan daftar** memakai email (Supabase Auth).

## Arsitektur
| Bagian | Teknologi |
|---|---|
| App | Flutter, Provider |
| Scan bahan | TFLite (`assets/model/model.tflite`, `labels.txt`) |
| Akun dan stok | Supabase (Auth + tabel `stock_items`) |
| Resep | Backend FastAPI terpisah (`POST /recommend`) |
| Terjemahan resep (opsional) | Gemini API |

## Menjalankan
1. `flutter pub get`
2. Salin `lib/core/config.example.dart` menjadi `lib/core/config.dart`, lalu isi Project URL dan Publishable key Supabase milikmu. File `config.dart` tidak ikut repositori.
3. Siapkan tabel `stock_items` di Supabase (kolom: `id`, `user_id`, `name`, `amount`, `unit`, `category`, `emoji`, `expiry`) dan aktifkan Row Level Security agar tiap pengguna hanya melihat stoknya sendiri.
4. Jalankan:
   ```
   flutter run --dart-define=BACKEND_URL=http://IP-BACKEND:8000
   ```
   Tambahkan `--dart-define=GEMINI_API_KEY=...` untuk menerjemahkan resep ke Bahasa Indonesia. Jangan menulis key di dalam kode.

Backend resep ada di repositori terpisah. Tanpa backend, fitur scan, login, dan stok tetap berjalan.

## Catatan
- Model scan menerima gambar 224x224 dengan nilai piksel mentah 0 sampai 255. Kelas "bukan rempah" dianggap tidak terdeteksi.
- Resep dari backend masih berbahasa Inggris tanpa key Gemini.
