import 'dart:io';

import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/maintenance/data/fuel_pump_image_variants.dart';
import 'package:fines_plus/features/maintenance/domain/fuel_pump_fuel_detector.dart';
import 'package:fines_plus/features/maintenance/domain/fuel_pump_reading_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// What was read off a pump photo: litres / price / total ([reading]) and the
/// grade named on the pump ([fuel]), each null when not found. [cancelled] is
/// true when the user backed out of the camera.
typedef FuelPumpScan = ({FuelPumpReading? reading, FuelType? fuel, bool cancelled});

/// Takes a photo of a fuel pump and reads its display and grade label,
/// recognised on-device.
///
/// A seven-segment display is hard for a text recognizer and each pass misses
/// different digits, so the photo is read as taken first and, only if that
/// isn't enough, again after contrast changes - see
/// [FuelPumpReadingParser.parsePasses].
class FuelPumpScanner {
  static const MethodChannel _channel = MethodChannel('fines_plus/text_recognition');
  final ImagePicker _picker = ImagePicker();

  Future<FuelPumpScan> readPump() async {
    final variants = <String>[];
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 2400);
      if (photo == null) return (reading: null, fuel: null, cancelled: true);
      final passes = <List<String>>[await _recognize(photo.path)];
      var reading = FuelPumpReadingParser.parse(passes.first);
      if (reading == null) {
        variants.addAll(await FuelPumpImageVariants.create(photo.path));
        for (final path in variants) {
          passes.add(await _recognize(path));
        }
        reading = FuelPumpReadingParser.parsePasses(passes);
      }
      return (reading: reading, fuel: FuelPumpFuelDetector.detect(passes.expand((lines) => lines)), cancelled: false);
    } catch (e) {
      debugPrint('Fuel pump scan failed: $e');
      return (reading: null, fuel: null, cancelled: false);
    } finally {
      for (final path in variants) {
        File(path).delete().ignore();
      }
    }
  }

  Future<List<String>> _recognize(String path) async =>
      await _channel.invokeListMethod<String>('recognizeLines', path) ?? const <String>[];
}
