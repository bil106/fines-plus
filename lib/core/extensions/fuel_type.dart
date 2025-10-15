
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';

enum FuelType { ai98, ai95Plus, ai95, ai92, lpg, diesel }
extension FuelTypeExt on FuelType {
  String localized(BuildContext context) {
    switch (this) {
      case FuelType.ai98:
        return S.of(context).fuel_ai98;
      case FuelType.ai95Plus:
        return S.of(context).fuel_ai95_plus;
      case FuelType.ai95:
        return S.of(context).fuel_ai95;
      case FuelType.ai92:
        return S.of(context).fuel_ai92;
      case FuelType.lpg:
        return S.of(context).fuel_gas_lpg;
      case FuelType.diesel:
        return S.of(context).fuel_gas_lpg;
    }
  }
}
final Map<FuelType, int> fuelPrices = {
  FuelType.ai98: 60,
  FuelType.ai95Plus: 62,
  FuelType.ai95: 55,
  FuelType.ai92: 47,
  FuelType.lpg: 30,
  FuelType.diesel: 60,
};
