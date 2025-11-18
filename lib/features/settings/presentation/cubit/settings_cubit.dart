import 'dart:async';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/settings/domain/services/settings_service.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';


class SettingsCubit extends Cubit<SettingsState> {
  final CurrencyService currencyService;

  late final StreamSubscription _settingsSub;
  StreamSubscription? _currencySub;

  SettingsCubit({required this.currencyService}) : super(SettingsService.instance.current) {
    /// Subscribe to settings changes
    _settingsSub = SettingsService.instance.stream.listen(emit);

    /// Subscribe to exchange rate updates
    _currencySub = currencyService.currencyStream.listen((_) {
      emit(state.copyWith()); // forces the UI to refresh
    });
  }

  // Methods simply call the service.с
  Future<void> setUnit(String value) => SettingsService.instance.setUnit(value);

  Future<void> setCurrency(String value) => SettingsService.instance.setCurrency(value);

  Future<void> setLocale(Locale locale) => SettingsService.instance.setLocale(locale);

  Future<void> setFuelConsumptionUnit(String value) => SettingsService.instance.setFuelConsumptionUnit(value);

  double convertFromUAH(double amountUAH) => currencyService.convert(amountUAH, state.currency, fromCurrency: "UAH");

  @override
  Future<void> close() async {
    await _settingsSub.cancel();
    await _currencySub?.cancel();
    return super.close();
  }
}
