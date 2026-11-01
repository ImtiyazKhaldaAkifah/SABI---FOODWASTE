import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const teal = Color(0xFF0E8A87);
  static const bgTop = Color(0xFFEFFDF8);
  static const bgBottom = Color(0xFFC9F5EA);
  static const red = Color(0xFFE53935);
  static const orange = Color(0xFFF5A623);
  static const green = Color(0xFF4CAF8E);
}

TextStyle ts({double size = 14, FontWeight w = FontWeight.w600, Color color = Colors.black}) =>
    GoogleFonts.comicNeue(fontSize: size, fontWeight: w, color: color);

Color daysColor(int d) => d <= 2 ? C.red : (d <= 5 ? C.orange : C.green);

class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.bgTop, C.bgBottom]),
        ),
        child: child,
      );
}

class SabiField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool password;
  const SabiField({super.key, required this.hint, required this.controller, this.password = false});
  @override
  State<SabiField> createState() => _SabiFieldState();
}

class _SabiFieldState extends State<SabiField> {
  bool hide = true;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 8, offset: const Offset(3, 5))],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.password && hide,
          style: ts(size: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: ts(size: 13, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: widget.password
                ? IconButton(
                    icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                    onPressed: () => setState(() => hide = !hide))
                : null,
          ),
        ),
      );
}

class SabiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const SabiButton(this.text, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: C.teal,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 8, offset: const Offset(3, 6))],
          ),
          child: Text(text, style: ts(size: 20, w: FontWeight.w900, color: Colors.white)),
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const Pill(this.text, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: C.teal, borderRadius: BorderRadius.circular(20)),
          child: Text(text, style: ts(size: 11, w: FontWeight.w800, color: Colors.white)),
        ),
      );
}

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 70});
  @override
  Widget build(BuildContext context) => Text('SABÍ', style: ts(size: size, w: FontWeight.w900, color: C.teal));
}

/// Gambar dari assets, kalau belum ada tampil emoji.
class AssetImg extends StatelessWidget {
  final String? path;
  final String fallback;
  final double? w, h;
  final BoxFit fit;
  const AssetImg(this.path, {super.key, this.fallback = '🍽️', this.w, this.h, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    Widget fb() => Container(width: w, height: h, alignment: Alignment.center, child: Text(fallback, style: TextStyle(fontSize: (h ?? 60) * .5)));
    if (path == null) return fb();
    return Image.asset(path!, width: w, height: h, fit: fit, errorBuilder: (_, __, ___) => fb());
  }
}
