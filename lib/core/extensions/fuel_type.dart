
// ignore_for_file: constant_identifier_names

import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';

enum FuelType { Ai98, Ai95Plus, Ai95, Ai92, LPG, DIESEl }
extension FuelTypeExt on FuelType {
  String localized(BuildContext context) {
    switch (this) {
      case FuelType.Ai98:
        return S.of(context).fuel_ai98;
      case FuelType.Ai95Plus:
        return S.of(context).fuel_ai95_plus;
      case FuelType.Ai95:
        return S.of(context).fuel_ai95;
      case FuelType.Ai92:
        return S.of(context).fuel_ai92;
      case FuelType.LPG:
        return S.of(context).fuel_gas_lpg;
      case FuelType.DIESEl:
        return S.of(context).fuel_gas_lpg;
    }
  }
}
final Map<FuelType, int> fuelPrices = {
  FuelType.Ai98: 60,
  FuelType.Ai95Plus: 62,
  FuelType.Ai95: 55,
  FuelType.Ai92: 47,
  FuelType.LPG: 30,
  FuelType.DIESEl: 60,
};
