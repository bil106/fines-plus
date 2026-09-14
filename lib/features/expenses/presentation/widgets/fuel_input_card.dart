import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
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

class FuelInputCard extends StatelessWidget {
  final FuelType fuel;
  final TextEditingController volumeController;
  final TextEditingController priceController;
  final ValueChanged<String>? onPriceChanged;
  final FocusNode? volumeFocusNode;
  final FocusNode? priceFocusNode;

  const FuelInputCard({
    super.key,
    required this.fuel,
    required this.volumeController,
    required this.priceController,
    this.onPriceChanged,
    this.volumeFocusNode,
    this.priceFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radiusLarge,
        border: Border.all(color: AppColors.grey300, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station, color: AppColors.blue700),
          AppSpacers.horizontalSmallMedium,
          Expanded(
            child: TextField(
              controller: volumeController,
              focusNode: volumeFocusNode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0 L",
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).price_liter, style: textTheme.bodySmall?.copyWith(color: AppColors.black87)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_outlined, color: AppColors.blue700),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 33,
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
                      style: textTheme.titleMedium?.copyWith(color: AppColors.black87),
                      onChanged: onPriceChanged,
                      onSubmitted: (_) => volumeFocusNode?.requestFocus(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Builder(
                    builder: (context) {
                      final settingsCubit = context.watch<SettingsCubit>();
                      final currencyLabel = settingsCubit.getCurrencyLabel(context, settingsCubit.state.currency);

                      return Text(
                        currencyLabel,
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
