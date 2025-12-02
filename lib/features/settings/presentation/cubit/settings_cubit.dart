import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsCubit extends Cubit<SettingsState> {
  late SharedPreferences _prefs;
  final CurrencyService currencyService;
  SettingsCubit({required this.currencyService})
    : super(SettingsState(unit: 'km', currency: 'UAH', locale: const Locale('uk'), fuelConsumptionUnit: 'l/100km')) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    emit(
      state.copyWith(
        unit: _prefs.getString('unit') ?? state.unit,
        currency: _prefs.getString('currency') ?? state.currency,
        locale: Locale(_prefs.getString('locale') ?? 'uk'),
        fuelConsumptionUnit: _prefs.getString('fuelConsumptionUnit') ?? 'l/100km',
      ),
    );
  }

  void setFuelConsumptionUnit(String value) {
    _prefs.setString('fuelConsumptionUnit', value);
    emit(state.copyWith(fuelConsumptionUnit: value));
  }

  Future<void> setUnit(String unit) async {
    await _prefs.setString('unit', unit);
    emit(state.copyWith(unit: unit));
  }

  double convertFromUAH(double amountUAH) {
    return currencyService.convert(amountUAH, state.currency, fromCurrency: "UAH");
  }
double convertToUAH(double amount) {
    return currencyService.convert(amount, "UAH", fromCurrency: state.currency);
  }
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString('localeCode', locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> setCurrency(String newCurrency) async {
    await _prefs.setString('currency', newCurrency);

    await currencyService.setCurrency(newCurrency);

    emit(state.copyWith(currency: newCurrency));
  }

  String getCurrencyLabel(BuildContext context, String currency) {
    final s = S.of(context);

    switch (currency) {
      case 'UAH':
        return s.grn;
      case 'USD':
        return s.usd;
      case 'EUR':
        return s.eur;
      default:
        return currency;
    }
  }



}
