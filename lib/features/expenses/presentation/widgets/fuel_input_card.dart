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
    await prefs.setDouble('fuel_price_$fuelName', price.roundToDouble());
  }

  static Future<double?> getPrice(String fuelName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('fuel_price_$fuelName');
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
  final ValueChanged<String>? onPriceChanged;
  final FocusNode? volumeFocusNode;
  final FocusNode? priceFocusNode;

  const FuelPriceVolumeSumRow({
    super.key,
    required this.volumeController,
    required this.priceController,
    this.onPriceChanged,
    this.volumeFocusNode,
    this.priceFocusNode,
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
            label: S.of(context).price_per_liter_short,
            child: TextField(
              controller: priceController,
              focusNode: priceFocusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
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
            label: S.of(context).volume_liters_short,
            child: TextField(
              controller: volumeController,
              focusNode: volumeFocusNode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0",
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
            ),
          ),
        ),
        AppSpacers.horizontalSmallMedium,
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: priceController,
            builder: (context, priceValue, _) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: volumeController,
                builder: (context, volumeValue, __) {
                  final liters = double.tryParse(volumeValue.text) ?? 0;
                  final price = double.tryParse(priceValue.text) ?? 0;
                  final total = (liters * price).toStringAsFixed(0);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.energyBlue50,
                      borderRadius: AppBorders.radiusMedium,
                      border: Border.all(color: AppColors.energyBlue),
                    ),
                    child: _FieldColumn(
                      label: S.of(context).sum_short,
                      child: Text(
                        "$total $currencyLabel",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
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
