import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return GradientBg(
      child: SafeArea(
        child: FutureBuilder<Map<String, String>?>(
          future: AuthService.current(),
          builder: (_, snap) {
            final u = snap.data;
            return ListView(padding: const EdgeInsets.all(24), children: [
              Center(child: Text('PROFIL', style: ts(size: 24, w: FontWeight.w900))),
              const SizedBox(height: 20),
              const Center(child: CircleAvatar(radius: 44, backgroundColor: C.teal, child: Icon(Icons.person, size: 52, color: Colors.white))),
              const SizedBox(height: 12),
              Center(child: Text(u?['name'] ?? '-', style: ts(size: 20, w: FontWeight.w900))),
              Center(child: Text(u?['id'] ?? '', style: ts(size: 12, w: FontWeight.w500))),
              const SizedBox(height: 24),
              Row(children: [
                _stat('${s.items.length}', 'Total Stok'),
                const SizedBox(width: 12),
                _stat('${s.expiring.length}', 'Hampir Kadaluarsa'),
              ]),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: SwitchListTile(
                  activeColor: C.teal,
                  title: Text('Notifikasi H-3 Kadaluarsa', style: ts(size: 13)),
                  value: s.notifOn,
                  onChanged: (v) {
                    s.notifOn = v;
                    s.notifyListeners();
                  },
                ),
              ),
              const SizedBox(height: 24),
              SabiButton('KELUAR', onTap: () async {
                await AuthService.logout();
                if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              }),
            ]);
          },
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [Text(v, style: ts(size: 26, w: FontWeight.w900, color: C.teal)), Text(l, style: ts(size: 11, w: FontWeight.w500))]),
        ),
      );
}
