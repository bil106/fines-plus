import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


String formatCurrency(double value, BuildContext context, {required String fromCurrency}) {
  final settingsCubit = context.read<SettingsCubit>();
  final currencyService = context.read<CurrencyService>();
  final targetCurrency = settingsCubit.state.currency;

  if (fromCurrency == targetCurrency) return value.toStringAsFixed(0);

  final convertedValue = currencyService.convert(value, targetCurrency, fromCurrency: fromCurrency);

  return convertedValue.toStringAsFixed(0);
}



