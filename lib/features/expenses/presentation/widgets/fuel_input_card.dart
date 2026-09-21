import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuelPriceCache {
  static Future<void> savePrice(String fuelName, double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fuel_price_$fuelName', price);
  }

  static Future<double?> getPrice(String fuelName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('fuel_price_$fuelName');
  }
}

/// Tank capacity (liters) - or, for [electric], battery capacity (kWh) -
/// remembered per car, so a full-tank / full-charge fill-up doesn't need it
/// typed in every time.
class FuelTankCache {
  static String _key(String carNumber, bool electric) =>
      electric ? 'battery_capacity_$carNumber' : 'fuel_tank_volume_$carNumber';

  static Future<void> saveVolume(String carNumber, double amount, {bool electric = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key(carNumber, electric), amount);
  }

  static Future<double?> getVolume(String carNumber, {bool electric = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key(carNumber, electric));
  }
}

/// The dashboard "Паливо" sheet's price/volume/sum row - three equal-width
/// fields side by side (price and volume editable, sum computed and
/// visually called out), matching the Fines+OS mockup. Replaces the older
/// two-card layout (a combined volume+price card, plus a separate sum+
/// full-tank card).
class FuelPriceVolumeSumRow extends StatelessWidget {
  final TextEditingController volumeController;
  final TextEditingController priceController;
  final TextEditingController sumController;
  final ValueChanged<String>? onPriceChanged;
  final ValueChanged<String>? onVolumeChanged;
  final ValueChanged<String>? onSumChanged;
  final FocusNode? volumeFocusNode;
  final FocusNode? priceFocusNode;

  /// Electricity: the price and amount fields are per kWh instead of per liter.
  final bool electric;

  const FuelPriceVolumeSumRow({
    super.key,
    required this.volumeController,
    required this.priceController,
    required this.sumController,
    this.onPriceChanged,
    this.onVolumeChanged,
    this.onSumChanged,
    this.volumeFocusNode,
    this.priceFocusNode,
    this.electric = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();
    final currencyLabel = settingsCubit.getCurrencyLabel(context, settingsCubit.state.currency);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppFieldCard(
            label: electric ? S.of(context).price_per_kwh_short : S.of(context).price_per_liter_short,
            child: TextField(
              controller: priceController,
              focusNode: priceFocusNode,
              keyboardType: electric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
              textInputAction: TextInputAction.next,
              // A kWh costs a few UAH, so electricity takes cents; a liter of
              // fuel stays a whole number.
              inputFormatters: electric
                  ? [_KwhPriceFormatter()]
                  : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0",
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
              onChanged: onPriceChanged,
              onSubmitted: (_) => volumeFocusNode?.requestFocus(),
            ),
          ),
        ),
        AppSpacers.horizontalSmallMedium,
        Expanded(
          child: AppFieldCard(
            label: electric ? S.of(context).volume_kwh_short : S.of(context).volume_liters_short,
            child: TextField(
              controller: volumeController,
              focusNode: volumeFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0",
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
              onChanged: onVolumeChanged,
            ),
          ),
        ),
        AppSpacers.horizontalSmallMedium,
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.energyBlue50,
              borderRadius: AppBorders.radiusMedium,
              border: Border.all(color: AppColors.energyBlue),
            ),
            child: _FieldColumn(
              label: S.of(context).sum_short,
              child: TextField(
                controller: sumController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "0",
                  suffixText: currencyLabel,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                onChanged: onSumChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Up to three digits and two decimals; accepts a comma as the decimal
/// separator (many keyboards only offer one) and stores it as a dot so the
/// value parses.
class _KwhPriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(',', '.');
    final parts = text.split('.');
    final digitsOnly = parts.every((part) => part.codeUnits.every((unit) => unit >= 48 && unit <= 57));
    final valid = parts.length <= 2 && digitsOnly && parts[0].length <= 3 && (parts.length == 1 || parts[1].length <= 2);
    return valid ? newValue.copyWith(text: text) : oldValue;
  }
}

class _FieldColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.black87)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
