import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';

/// Login & daftar lewat Supabase Auth (email + kata sandi).
class AuthService {
  static const _notReady = 'Supabase belum diatur. Isi URL dan key di lib/core/config.dart';

  static SupabaseClient get _c => Supabase.instance.client;

  static Future<String?> register(String name, String email, String pass) async {
    if (!AppConfig.ready) return _notReady;
    if (!email.contains('@')) return 'Daftar pakai email dulu ya (nomor HP belum didukung)';
    if (pass.length < 6) return 'Kata sandi minimal 6 karakter';
    try {
      final res = await _c.auth.signUp(email: email, password: pass, data: {'name': name});
      if (res.session == null) return 'Akun dibuat. Cek email untuk konfirmasi, lalu masuk.';
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal daftar: $e';
    }
  }

  static Future<String?> login(String email, String pass) async {
    if (!AppConfig.ready) return _notReady;
    if (!email.contains('@')) return 'Masuk pakai email ya (nomor HP belum didukung)';
    try {
      await _c.auth.signInWithPassword(email: email, password: pass);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal masuk: $e';
    }
  }

  static Future<Map<String, String>?> current() async {
    if (!AppConfig.ready) return null;
    final u = _c.auth.currentUser;
    if (u == null) return null;
    return {'id': u.email ?? '', 'name': '${u.userMetadata?['name'] ?? 'Pengguna'}'};
  }

  static Future<void> logout() async {
    if (AppConfig.ready) await _c.auth.signOut();
  }
}