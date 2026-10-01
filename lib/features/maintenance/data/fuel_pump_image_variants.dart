import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;

/// Re-renders a photo of a pump display so a text recognizer, built for print,
/// has a better chance with its dim seven-segment digits.
class FuelPumpImageVariants {
  const FuelPumpImageVariants._();

  /// Files for the contrast-boosted and the inverted version of [path], in
  /// the temp directory. The caller deletes them. Empty when the photo can't
  /// be decoded.
  static Future<List<String>> create(String path) => Isolate.run(() {
    final decoded = img.decodeImage(File(path).readAsBytesSync());
    if (decoded == null) return const <String>[];
    final gray = img.grayscale(img.bakeOrientation(decoded));
    final contrast = img.contrast(img.normalize(gray, min: 0, max: 255), contrast: 170);
    final inverted = img.invert(contrast.clone());
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final paths = <String>[];
    for (final (name, image) in [('contrast', contrast), ('inverted', inverted)]) {
      final file = File('${Directory.systemTemp.path}/pump_${stamp}_$name.jpg');
      file.writeAsBytesSync(img.encodeJpg(image, quality: 92));
      paths.add(file.path);
    }
    return paths;
  });
}
