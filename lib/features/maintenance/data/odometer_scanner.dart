import 'package:fines_plus/features/maintenance/domain/odometer_reading_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Takes a photo of the dashboard and reads the odometer off it, recognised
/// on-device. [cancelled] is true when the user backed out of the camera;
/// otherwise a null [reading] means nothing plausible was found.
class OdometerScanner {
  final ImagePicker _picker = ImagePicker();

  /// [lastKnown] (same unit as the result) filters out values the odometer
  /// can't have, see [OdometerReadingParser.parse].
  Future<({int? reading, bool cancelled})> readMileage({int? lastKnown}) async {
    TextRecognizer? recognizer;
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1600);
      if (photo == null) return (reading: null, cancelled: true);
      recognizer = TextRecognizer();
      final result = await recognizer.processImage(InputImage.fromFilePath(photo.path));
      final lines = [
        for (final block in result.blocks)
          for (final line in block.lines) line.text,
      ];
      return (reading: OdometerReadingParser.parse(lines, lastKnown: lastKnown), cancelled: false);
    } catch (e) {
      debugPrint('Odometer scan failed: $e');
      return (reading: null, cancelled: false);
    } finally {
      await recognizer?.close();
    }
  }
}
