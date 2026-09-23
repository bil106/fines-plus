import 'package:fines_plus/features/vehicle/data/car_makes.dart';
import 'package:fines_plus/features/vehicle/data/car_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every make in the picker has model suggestions', () {
    for (final make in carMakes) {
      expect(carModels[make], isNotEmpty, reason: make);
    }
  });
}
