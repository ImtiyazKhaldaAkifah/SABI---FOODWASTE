# 🍎 SABI - Pangan Terjaga, Bumi Bahagia

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![TensorFlow Lite](https://img.shields.io/badge/TensorFlow_Lite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)

**SABI** (Sistem Anti Food Waste) adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu mengurangi limbah makanan (food waste) di rumah tangga. Aplikasi ini memungkinkan pengguna untuk memindai bahan makanan, memantau tanggal kadaluarsa, dan secara otomatis mendapatkan rekomendasi resep masakan menggunakan kecerdasan buatan (AI).

## ✨ Fitur Utama

- 📸 **Pemindaian Bahan Otomatis**: Menggunakan model *TensorFlow Lite* (TFLite) untuk mendeteksi jenis bahan makanan melalui kamera.
- 📦 **Manajemen Stok Pintar**: Menyimpan dan memantau daftar stok bahan makanan secara *real-time* dengan sinkronisasi *cloud* (Supabase).
- ⏳ **Pengingat Kadaluarsa**: Notifikasi otomatis untuk bahan makanan yang akan segera kadaluarsa (H-3).
- 🍳 **Generator Resep AI**: Memanfaatkan **Google Gemini AI** untuk menghasilkan resep masakan dalam Bahasa Indonesia yang disesuaikan dengan sisa stok bahan pengguna.
- 📴 **Offline Mode**: Resep terakhir yang di-*generate* akan disimpan secara lokal (menggunakan `shared_preferences`), sehingga dapat diakses kembali meskipun tanpa koneksi internet.

## 🛠️ Teknologi & Arsitektur

Aplikasi ini dibangun menggunakan *stack* teknologi modern:
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend & Auth**: [Supabase](https://supabase.com/)
- **Machine Learning**: [tflite_flutter](https://pub.dev/packages/tflite_flutter) & [camera](https://pub.dev/packages/camera)
- **AI Integration**: [Google Gemini API](https://ai.google.dev/)
- **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Notifikasi**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

## 🚀 Cara Menjalankan Project (Local Development)

Ikuti langkah-langkah berikut untuk menjalankan aplikasi di lingkungan lokal kamu:

### Prasyarat
- Flutter SDK (versi 3.19 atau lebih baru)
- Android Studio / Xcode (untuk emulator)
- Akun Supabase (untuk database)
- API Key Google Gemini (dari [Google AI Studio](https://aistudio.google.com/))

### Instalasi
1. **Clone repository ini:**
   ```bash
   git clone https://github.com/ImtiyazKhaldaAkifah/SABI---FOODWASTE.git
   cd SABI---FOODWASTE
