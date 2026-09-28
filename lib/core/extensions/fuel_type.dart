
// ignore_for_file: constant_identifier_names

import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// A stored fuel amount (liters, or kWh for electricity) as the user reads
/// it: "40 l." or, with US units, "10.6 gal". Liters keep the caller's
/// formatting ([wholeLiters] drops the fraction), gallons get one decimal.
String fuelAmountLabel(BuildContext context, String name, double amount, {bool wholeLiters = false}) {
  final units = UnitStream(context.read<SettingsCubit>());
  if (!(fuelTypeFromName(name)?.isElectric ?? false) && units.usesGallons) {
    return '${units.litersToDisplay(amount).toStringAsFixed(1)} ${S.of(context).gal}';
  }
  final value = wholeLiters ? amount.toInt().toString() : amount.toString();
  return '$value ${fuelUnitLabel(context, name)}';
}

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
