import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'recipe_screen.dart';
import 'scan_screen.dart';
import 'stock_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;

  @override
  void initState() {
    super.initState();
    // ambil stok milik akun yang sedang login dari Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().load());
  }

  void go(int n) => setState(() => i = n);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onTab: go),
      const StockScreen(),
      i == 2 ? ScanScreen(onClose: () => go(0)) : const SizedBox(), // kamera hanya aktif saat tab Input
      const RecipeScreen(),
      const ProfileScreen(),
    ];
    const nav = [
      (Icons.home_rounded, 'Beranda'),
      (Icons.inventory_2_rounded, 'Stok'),
      (Icons.crop_free_rounded, 'Input'),
      (Icons.assignment_outlined, 'Resep'),
      (Icons.person_outline_rounded, 'Profil'),
    ];
    return Scaffold(
      body: IndexedStack(index: i, children: pages),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var n = 0; n < nav.length; n++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => go(n),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(nav[n].$1, size: 28, color: i == n ? C.teal : Colors.grey[600]),
                      Text(nav[n].$2, style: ts(size: 10, color: i == n ? C.teal : Colors.grey[600]!)),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}