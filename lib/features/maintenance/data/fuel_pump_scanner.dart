import 'dart:io';

import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/maintenance/data/fuel_pump_image_variants.dart';
import 'package:fines_plus/features/maintenance/domain/fuel_pump_fuel_detector.dart';
import 'package:fines_plus/features/maintenance/domain/fuel_pump_reading_parser.dart';
import 'package:fines_plus/features/maintenance/domain/gallon_pump_reading_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// What was read off a pump photo: volume / price / total ([reading], in the
/// pump's unit) and the grade named on the pump ([fuel]), each null when not
/// found. [cancelled] is
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

  /// [gallons] is for US pumps, which show gallons and a price per gallon. Their
  /// panels list every grade, so the fuel isn't guessed from the labels.
  /// [onPhotoTaken] fires once the camera returns a photo, before recognition.
  Future<FuelPumpScan> readPump({bool gallons = false, VoidCallback? onPhotoTaken}) async {
    final variants = <String>[];
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 2400);
      if (photo == null) return (reading: null, fuel: null, cancelled: true);
      onPhotoTaken?.call();
      final passes = <List<String>>[await _recognize(photo.path)];
      var reading = gallons ? GallonPumpReadingParser.parsePasses(passes) : FuelPumpReadingParser.parse(passes.first);
      if (reading == null) {
        variants.addAll(await FuelPumpImageVariants.create(photo.path));
        for (final path in variants) {
          passes.add(await _recognize(path));
        }
        reading = gallons ? GallonPumpReadingParser.parsePasses(passes) : FuelPumpReadingParser.parsePasses(passes);
      }
      final fuel = gallons ? null : FuelPumpFuelDetector.detect(passes.expand((lines) => lines));
      return (reading: reading, fuel: fuel, cancelled: false);
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
