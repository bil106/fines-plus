import 'dart:async';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  final _controller = StreamController<SettingsState>.broadcast();
  late SharedPreferences _prefs;

  SettingsState _current = SettingsState(
    unit: 'km',
    currency: 'UAH',
    locale: const Locale('uk'),
    fuelConsumptionUnit: 'l/100km',
  );

  Stream<SettingsState> get stream => _controller.stream;
  SettingsState get current => _current;

  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _current = _current.copyWith(
      unit: _prefs.getString('unit'),
      currency: _prefs.getString('currency'),
      locale: Locale(_prefs.getString('locale') ?? 'uk'),
      fuelConsumptionUnit: _prefs.getString('fuelConsumptionUnit'),
    );

    _controller.add(_current);
  }

  void _update(SettingsState newValue) {
    _current = newValue;
    _controller.add(_current);
  }

  Future<void> setUnit(String value) async {
    await _prefs.setString('unit', value);
    _update(_current.copyWith(unit: value));
  }

  Future<void> setCurrency(String value) async {
    await _prefs.setString('currency', value);
    _update(_current.copyWith(currency: value));
  }

  Future<void> setLocale(Locale value) async {
    await _prefs.setString('locale', value.languageCode);
    _update(_current.copyWith(locale: value));
  }

  Future<void> setFuelConsumptionUnit(String value) async {
    await _prefs.setString('fuelConsumptionUnit', value);
    _update(_current.copyWith(fuelConsumptionUnit: value));
  }
}
