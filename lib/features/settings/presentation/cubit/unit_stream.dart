// ignore_for_file: unused_local_variable

import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';

class UnitStream {
  final SettingsCubit settingsCubit;

  UnitStream(this.settingsCubit);

  Stream<double> unitValueStream(double kmValue) {
    return settingsCubit.stream.map((state) => convert(kmValue)).distinct();
  }

  double convert(double kmValue) {
    if (settingsCubit.state.unit == 'mil') {
      return kmValue * 0.621371;
    }

    return kmValue;
  }

  Stream<double> fuelConsumptionStream(double lPer100km) {
    return settingsCubit.stream.map((state) => convertFuel(lPer100km)).distinct();
  }

  double convertFuel(double lPer100km) {
    return settingsCubit.state.unit == 'km' ? lPer100km : 235.214 / lPer100km;
  }
}
