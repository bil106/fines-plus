import 'package:fines_plus/features/maintenance/domain/odometer_reading_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Takes a photo of the dashboard and reads the odometer off it, recognised
/// on-device. [cancelled] is true when the user backed out of the camera;
/// otherwise a null [reading] means nothing plausible was found.
class OdometerScanner {
  static const MethodChannel _channel = MethodChannel('fines_plus/text_recognition');
  final ImagePicker _picker = ImagePicker();

  /// [lastKnown] (same unit as the result) filters out values the odometer
  /// can't have, see [OdometerReadingParser.parse].
  Future<({int? reading, bool cancelled})> readMileage({int? lastKnown}) async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1600);
      if (photo == null) return (reading: null, cancelled: true);
      final lines = await _channel.invokeListMethod<String>('recognizeLines', photo.path) ?? const <String>[];
      return (reading: OdometerReadingParser.parse(lines, lastKnown: lastKnown), cancelled: false);
    } catch (e) {
      debugPrint('Odometer scan failed: $e');
      return (reading: null, cancelled: false);
    }
  }
}
