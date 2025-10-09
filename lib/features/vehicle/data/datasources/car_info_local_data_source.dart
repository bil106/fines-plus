
import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:flutter/material.dart';


class CarInfoLocalDataSource {
  CarInfoLocalDataSource(this.prefs);

  final SharedPrefsManager prefs;

  static const _carKey = 'car_number';
  static const _techKey = 'tech_passport';
  static const _seriesKey = 'doc_series';
  static const _numberKey = 'doc_number';

  Future<void> saveCarInfo(CarInfoModel model) async {
    final car = model.carNumber.trim();
    final tech = model.techPassport.trim();

    await prefs.setString(_carKey, car);
    await prefs.setString(_techKey, tech);

    if (tech.length == 9) {
      final series = tech.substring(0, 3);
      final number = tech.substring(3);
      await prefs.setString(_seriesKey, series);
      await prefs.setString(_numberKey, number);

      debugPrint("Saved tech passport split: series=$series, number=$number");
    }

    debugPrint("Saved car info: number=$car, tech=$tech");
  }

  Future<CarInfoModel> getCarInfo() async {
    final car = prefs.getString(_carKey) ?? '';
    final tech = prefs.getString(_techKey) ?? '';
    final series = prefs.getString(_seriesKey) ?? '';
    final number = prefs.getString(_numberKey) ?? '';

    debugPrint("📥 Loaded car info: number=$car, tech=$tech, series=$series, num=$number");

    return CarInfoModel(
      carNumber: car,
      techPassport: tech, ownerId: '',
    );
  }

  Future<void> saveCarNumber(String v) async => prefs.setString(_carKey, v.trim());

  Future<void> saveTechPassport(String v) async {
    final value = v.trim().toUpperCase();
    await prefs.setString(_techKey, value);

    if (value.length == 9) {
      final series = value.substring(0, 3);
      final number = value.substring(3);
      await prefs.setString(_seriesKey, series);
      await prefs.setString(_numberKey, number);

      debugPrint("Saved tech passport split (via saveTechPassport): series=$series, number=$number");
    }
  }
}
