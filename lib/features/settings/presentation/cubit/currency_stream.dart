// ignore_for_file: unused_local_variable

import 'package:fines_plus/features/home/domain/entities/last_event_ui_model.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';


class CurrencyStream {
  final SettingsCubit settingsCubit;
  CurrencyStream(this.settingsCubit);

  Stream<double> convertedAmountStream(LastEventUiModel event) async* {
 
    double value = event.amountOriginal ?? event.amountValue;
    yield _convert(value, event);

  
    await for (final state in settingsCubit.stream) {
      value = event.amountOriginal ?? event.amountValue;
      yield _convert(value, event);
    }
  }

double _convert(double value, LastEventUiModel event) {
    final targetCurrency = settingsCubit.state.currency;
    final fromCurrency = event.originalCurrency ?? 'UAH'; 
    return settingsCubit.currencyService.convert(value, targetCurrency, fromCurrency: fromCurrency);
  }


}
