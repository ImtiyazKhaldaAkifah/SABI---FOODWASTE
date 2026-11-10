import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'account_settings_screen.dart'; 
// 🔴 TAMBAHAN IMPORT BUAT HALAMAN BARU
import 'about_screen.dart';
import 'help_screen.dart';
import 'faq_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _imageFile = File(path));
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Pengguna SABI';
    final userEmail = user?.email ?? 'email@contoh.com';

    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('PROFIL PENGGUNA', style: ts(size: 18, w: FontWeight.w900)),
                const SizedBox(height: 24),

                // --- CARD USER ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange.shade100),
                              child: ClipOval(
                                child: _imageFile != null
                                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    : Image.network(
                                        'https://api.dicebear.com/7.x/avataaars/png?seed=$userName',
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Center(child: Text('🧑', style: TextStyle(fontSize: 35))),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: C.teal, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName.toUpperCase(), style: ts(size: 16, w: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(userEmail, style: ts(size: 12, w: FontWeight.w500, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- CARD STATISTIK ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        decoration: BoxDecoration(color: C.teal, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Text('${s.items.length}', style: ts(size: 32, w: FontWeight.w900, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Total Stok\nMakanan', textAlign: TextAlign.center, style: ts(size: 11, w: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Text('${s.expiring.length}', style: ts(size: 32, w: FontWeight.w900, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Hampir\nKadaluarsa', textAlign: TextAlign.center, style: ts(size: 11, w: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- MENU LIST ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined, color: Colors.black87),
                        title: Text('Notifikasi Kadaluarsa', style: ts(size: 13, w: FontWeight.w600)),
                        trailing: Switch(
                          value: s.notifOn,
                          activeColor: C.teal,
                          onChanged: (val) { s.notifOn = val; s.notifyListeners(); },
                        ),
                      ),
                      const Divider(height: 1),
                      _menuItem(context, Icons.person_outline, 'Pengaturan Akun', const AccountSettingsScreen()),
                      const Divider(height: 1),
                      // 🔴 INI YANG UDAH DISAMBUNGIN KE HALAMAN BARU 🔴
                      _menuItem(context, Icons.info_outline, 'Tentang Aplikasi', const AboutScreen()),
                      const Divider(height: 1),
                      _menuItem(context, Icons.help_outline, 'Bantuan', const HelpScreen()),
                      const Divider(height: 1),
                      _menuItem(context, Icons.question_answer_outlined, 'FAQ', const FaqScreen()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- TOMBOL KELUAR ---
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('KELUAR', style: ts(size: 14, w: FontWeight.w900, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, [Widget? destination]) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: ts(size: 13, w: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(title, style: ts(size: 16, w: FontWeight.w900)),
                content: Text('Halaman $title masih dalam tahap pengembangan oleh developer.', style: ts(size: 13, w: FontWeight.w500)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('TUTUP', style: ts(size: 13, w: FontWeight.w900, color: C.teal)),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}