import 'package:flutter/material.dart';

class SettingsState {
  final String unit;
  final String currency;
  final Locale locale;
  final String fuelConsumptionUnit; 

  SettingsState({required this.unit, required this.currency, required this.locale, required this.fuelConsumptionUnit});

  SettingsState copyWith({String? unit, String? currency, Locale? locale, String? fuelConsumptionUnit}) {
    return SettingsState(
      unit: unit ?? this.unit,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      fuelConsumptionUnit: fuelConsumptionUnit ?? this.fuelConsumptionUnit,
    );
  }
}
