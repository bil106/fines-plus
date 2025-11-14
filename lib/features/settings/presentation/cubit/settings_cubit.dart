import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState(unit: 'km', currency: 'UAH', locale: const Locale('uk'))) {
    _loadSettings();
  }

  late SharedPreferences _prefs;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final unit = _prefs.getString('unit') ?? 'km';
    final currency = _prefs.getString('currency') ?? 'UAH';
    final localeCode = _prefs.getString('localeCode') ?? 'uk';
    emit(SettingsState(unit: unit, currency: currency, locale: Locale(localeCode)));

  }

  Future<void> setUnit(String unit) async {
    await _prefs.setString('unit', unit);
    emit(state.copyWith(unit: unit));
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setString('currency', currency);
    emit(state.copyWith(currency: currency));
  }

  // Future<void> _loadSavedLocale() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final code = prefs.getString('localeCode');
  //   if (code != null) {
  //     emit(state.copyWith(locale: Locale(code)));
  //   }
  // }

Future<void> setLocale(Locale locale) async {
    await _prefs.setString('localeCode', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }


  // void setUnit(String value) => emit(state.copyWith(unit: value));
  // void setCurrency(String value) => emit(state.copyWith(currency: value));
}
