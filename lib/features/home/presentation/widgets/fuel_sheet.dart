import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/widget/app_bottom_sheet.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:flutter/material.dart';

/// The dashboard's fuel-up bottom sheet. Shared by the quick-add tile, the
/// "fuel paid by phone" link and the "log your fuel-up" notification, so all
/// three open the same sheet. [initialSum] pre-fills the paid total.
Future<FuelRecord?> showFuelSheet(BuildContext context, {double? initialSum}) {
  final fuelKey = GlobalKey<FuelUpScreenState>();
  return AppBottomSheet.show<FuelRecord>(
    context,
    title: S.of(context).fuel,
    contentBuilder: (_) => FuelUpScreen(key: fuelKey, embedded: true, initialSum: initialSum),
    saveLabel: S.of(context).save,
    onSave: () => fuelKey.currentState?.save(),
  );
}
