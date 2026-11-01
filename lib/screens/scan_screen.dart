import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/classifier_service.dart';
import '../services/shelf_life.dart';
import 'stock_screen.dart';

class ScanScreen extends StatefulWidget {
  final VoidCallback onClose;
  const ScanScreen({super.key, required this.onClose});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cam;
  final _clf = ClassifierService();
  XFile? _shot;
  ShelfInfo? _info;
  bool _busy = false, _torch = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCam();
  }

  Future<void> _initCam() async {
    try {
      final cams = await availableCameras();
      final c = CameraController(cams.first, ResolutionPreset.high, enableAudio: false);
      await c.initialize();
      if (!mounted) return;
      setState(() => _cam = c);
    } catch (e) {
      setState(() => _error = 'Kamera tidak bisa dibuka: $e');
    }
  }

  @override
  void dispose() {
    _cam?.dispose();
    _clf.dispose();
    super.dispose();
  }

  Future<void> _snap() async {
    if (_cam == null || _busy) return;
    setState(() => _busy = true);
    try {
      final f = await _cam!.takePicture();
      final r = await _clf.classify(File(f.path));
      setState(() {
        _shot = f;
        _info = r == null ? null : ShelfLife.lookup(r.label);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal scan: $e')));
    }
    setState(() => _busy = false);
  }

  void _retake() => setState(() {
        _shot = null;
        _info = null;
      });

  Future<void> _addToList() async {
    final i = _info;
    if (i == null) return;
    final state = context.read<AppState>();
    await state.addItem(FoodItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: i.name, amount: 1, unit: 'Buah', category: i.category, emoji: i.emoji,
        expiry: DateTime.now().add(Duration(days: i.fridge))));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${i.name} masuk daftar. Membuat resep AI...')));
    _retake();
    state.generateAi(focus: i.name); // resep AI dibuat dari bahan yang baru discan
  }

  Widget _chip(String t, {double size = 11}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
        child: Text(t, style: ts(size: size, color: Colors.white, w: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    final c = _cam;
    return Container(
      color: Colors.black,
      child: Stack(fit: StackFit.expand, children: [
        if (_shot != null)
          Image.file(File(_shot!.path), fit: BoxFit.cover)
        else if (c != null && c.value.isInitialized)
          ClipRect(child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: c.value.previewSize!.height, height: c.value.previewSize!.width, child: CameraPreview(c))))
        else
          Center(child: Text(_error ?? 'Membuka kamera...', style: ts(color: Colors.white))),
        // frame
        Positioned.fill(child: Padding(padding: const EdgeInsets.fromLTRB(30, 130, 30, 200), child: CustomPaint(painter: _Corners()))),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _round(Icons.close, widget.onClose),
                _chip('● MobileNet AI Mode: ON'),
                _round(Icons.bolt, () async {
                  _torch = !_torch;
                  await _cam?.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
                }),
              ]),
              const Spacer(),
              if (_info != null) ...[
                _chip('1 ${_info!.name}', size: 13),
                const SizedBox(height: 6),
                _chip('Kadaluarsa: ${_info!.fridge} hari penyimpanan kulkas'),
                const SizedBox(height: 6),
                _chip('${_info!.room} hari penyimpanan suhu ruangan'),
              ] else if (_shot != null)
                _chip('Makanan tidak dikenali, coba Inputasi Manual'),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(onTap: _retake, child: _chip('Ambil Ulang Foto')),
                GestureDetector(
                  onTap: _snap,
                  child: Container(width: 64, height: 64, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: _busy ? const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator(strokeWidth: 3)) : null),
                ),
                GestureDetector(onTap: _addToList, child: _chip('Masukkan Daftar')),
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(onTap: () => showAddItemSheet(context), child: _chip('Inputasi Manual')),
                const SizedBox(width: 14),
                GestureDetector(
                    onTap: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Panduan Inputasi'), content: Text('1. Taruh satu makanan di bidang polos.\n2. Pastikan cahaya cukup.\n3. Tekan tombol bulat.\n4. Cek hasil, lalu Masukkan Daftar.'))),
                    child: _chip('Panduan Inputasi')),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _round(IconData i, VoidCallback f) => GestureDetector(
      onTap: f, child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(i, size: 18, color: C.teal)));
}

class _Corners extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    const l = 50.0;
    for (final (x, y, dx, dy) in [(0.0, 0.0, 1.0, 1.0), (s.width, 0.0, -1.0, 1.0), (0.0, s.height, 1.0, -1.0), (s.width, s.height, -1.0, -1.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * l, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * l), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
