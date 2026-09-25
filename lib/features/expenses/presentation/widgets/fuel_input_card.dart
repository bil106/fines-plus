import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/decimal_input_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
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
    final brand = context.brandTheme;
    final accent = Theme.of(context).colorScheme.primary;
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              // Prices take cents: a kWh costs a few UAH, a US gallon ~$3.49.
              inputFormatters: const [DecimalInputFormatter(maxIntegerDigits: 3)],
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0",
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: textTheme.titleMedium
                  ?.merge(brand.moneyTextStyle)
                  .copyWith(fontSize: 15, color: AppColors.ink),
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
              style: textTheme.titleMedium
                  ?.merge(brand.moneyTextStyle)
                  .copyWith(fontSize: 15, color: AppColors.ink),
              onChanged: onVolumeChanged,
            ),
          ),
        ),
        AppSpacers.horizontalSmallMedium,
        Expanded(
          child: Material(
            color: Color.lerp(accent, AppColors.neutreBlanc, 0.88),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color.lerp(accent, AppColors.neutreBlanc, 0.7)!),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: _FieldColumn(
                label: S.of(context).sum_short,
                child: TextField(
                  controller: sumController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [DecimalInputFormatter()],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "0",
                    suffixText: currencyLabel,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: textTheme.titleMedium
                      ?.merge(brand.moneyTextStyle)
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                  onChanged: onSumChanged,
                ),
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
        Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11.5)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
