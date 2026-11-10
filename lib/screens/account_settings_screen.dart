import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // 🔴 TAMBAHAN
import 'package:shared_preferences/shared_preferences.dart'; // 🔴 TAMBAHAN
import '../core/theme.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoadingName = false;
  bool _isLoadingPass = false;

  // 🔴 VARIABEL BUAT FOTO
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.userMetadata?['full_name'] ?? '';
    _loadProfileImage(); // Panggil fungsi load foto
  }

  // 🔴 FUNGSI NGAMBIL FOTO DARI MEMORI
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _imageFile = File(path));
    }
  }

  // 🔴 FUNGSI MILIH FOTO DARI GALERI
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diubah!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  // Fungsi Simpan Nama
  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoadingName = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diubah!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah nama: $e')),
        );
      }
    }
    setState(() => _isLoadingName = false);
  }

  // Fungsi Ganti Password
  Future<void> _showChangePasswordDialog() async {
    _passController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Ganti Kata Sandi', style: ts(size: 18, w: FontWeight.w900)),
          content: TextField(
            controller: _passController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Masukkan kata sandi baru',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('BATAL', style: ts(color: Colors.grey, w: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPass = _passController.text;
                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kata sandi minimal 6 karakter!')),
                  );
                  return;
                }
                Navigator.pop(context);
                setState(() => _isLoadingPass = true);
                try {
                  await Supabase.instance.client.auth.updateUser(
                    UserAttributes(password: newPass),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kata sandi berhasil diubah!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal: $e')),
                    );
                  }
                }
                setState(() => _isLoadingPass = false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: C.teal),
              child: Text('SIMPAN', style: ts(color: Colors.white, w: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = user?.userMetadata?['full_name'] ?? 'Pengguna SABI';

    return Scaffold(
      backgroundColor: C.bgBottom,
      appBar: AppBar(
        title: Text('Pengaturan Akun', style: ts(size: 18, w: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER PROFIL KECIL (BISA DIKLIK) ---
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // 🔴 BISA DIKLIK BUAT GANTI FOTO
                      child: Stack(
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange.shade100),
                            child: ClipOval(
                              child: _imageFile != null
                                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                                  : Image.network(
                                      'https://api.dicebear.com/7.x/avataaars/png?seed=$userName',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Center(child: Text('🧑', style: TextStyle(fontSize: 50))),
                                    ),
                            ),
                          ),
                          // Ikon kamera kecil
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: C.teal, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user?.email ?? 'email@contoh.com', style: ts(size: 14, w: FontWeight.w600, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- SECTION 1: INFORMASI PRIBADI ---
              Text('Informasi Pribadi', style: ts(size: 14, w: FontWeight.w900, color: C.teal)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Lengkap', style: ts(size: 12, w: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama baru',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoadingName ? null : _saveName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoadingName 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('SIMPAN NAMA', style: ts(size: 13, w: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 2: KEAMANAN ---
              Text('Keamanan Akun', style: ts(size: 14, w: FontWeight.w900, color: C.teal)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.black87),
                  title: Text('Ganti Kata Sandi', style: ts(size: 14, w: FontWeight.w700)),
                  subtitle: Text('Amankan akunmu secara berkala', style: ts(size: 11, color: Colors.grey)),
                  trailing: _isLoadingPass 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: _isLoadingPass ? null : _showChangePasswordDialog,
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 3: ZONA BAHAYA ---
              Text('Zona Berbahaya', style: ts(size: 14, w: FontWeight.w900, color: Colors.red)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  title: Text('Hapus Akun', style: ts(size: 14, w: FontWeight.w700, color: Colors.red.shade700)),
                  subtitle: Text('Tindakan ini tidak dapat dibatalkan', style: ts(size: 11, color: Colors.grey)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Hapus Akun belum tersedia untuk saat ini.')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}