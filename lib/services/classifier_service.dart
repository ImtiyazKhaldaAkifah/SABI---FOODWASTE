import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifyResult {
  final String label;
  final double confidence;
  ClassifyResult(this.label, this.confidence);
}

/// Model MobileNetV2 buatan temanmu:
/// - input  : [1, 224, 224, 3] float32, nilai piksel MENTAH 0..255
///            (normalisasi sudah ada DI DALAM model, jadi jangan dibagi 255 lagi!)
/// - output : 59 kelas, urutan sama dengan assets/model/labels.txt
/// - kelas "bukan rempah" = bukan makanan yang dikenali -> dianggap tidak terdeteksi
class ClassifierService {
  static const _size = 224;
  static const _minConfidence = 0.2;
  static const _notFood = 'bukan rempah';

  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
    final raw = await rootBundle.loadString('assets/model/labels.txt');
    _labels = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  /// Mengembalikan null kalau tidak yakin / bukan makanan yang dikenali.
  Future<ClassifyResult?> classify(File file) async {
    if (_interpreter == null) await load();
    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) return null;
    final oriented = img.bakeOrientation(decoded);
    final r = img.copyResize(oriented, width: _size, height: _size, interpolation: img.Interpolation.linear);

    final input = [
      List.generate(
          _size,
          (y) => List.generate(_size, (x) {
                final p = r.getPixel(x, y);
                return [p.r.toDouble(), p.g.toDouble(), p.b.toDouble()];
              }))
    ];
    final output = [List<double>.filled(_labels.length, 0.0)];
    _interpreter!.run(input, output);

    final scores = output[0];
    var best = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) best = i;
    }
    final label = _labels[best].toLowerCase();
    final top = List.generate(scores.length, (i) => i)..sort((a, b) => scores[b].compareTo(scores[a]));
    print('SABI top3: ${top.take(3).map((i) => '${_labels[i]} ${(scores[i] * 100).toStringAsFixed(0)}%').join(', ')}');
    if (label == _notFood || scores[best] < _minConfidence) return null;
    return ClassifyResult(label, scores[best]);
  }

  void dispose() => _interpreter?.close();
}
