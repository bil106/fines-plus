
// ignore_for_file: constant_identifier_names

import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';

enum FuelType { Ai98, Ai95Plus, Ai95, Ai92, LPG, DIESEl, Electric }

/// The [FuelType] a stored `FuelRecord.fuelType` name refers to, or null for
/// an unknown / legacy value.
FuelType? fuelTypeFromName(String name) => FuelType.values.asNameMap()[name];

/// Localized name of a stored fuel type, falling back to the raw value.
String fuelTypeLabel(BuildContext context, String name) => fuelTypeFromName(name)?.localized(context) ?? name;

/// Unit a stored fuel type's amount is measured in: kWh for electricity,
/// liters otherwise.
String fuelUnitLabel(BuildContext context, String name) =>
    fuelTypeFromName(name)?.isElectric ?? false ? S.of(context).kwh : S.of(context).l;

extension FuelTypeExt on FuelType {
  bool get isElectric => this == FuelType.Electric;

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
        return S.of(context).fuel_chip_diesel;
      case FuelType.Electric:
        return S.of(context).fuel_electric;
    }
  }
}
