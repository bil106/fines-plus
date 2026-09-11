import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FuelAmountCard extends StatelessWidget {
  final TextEditingController volumeController;
  final TextEditingController priceController;
  final String? fullTankText;

  const FuelAmountCard({super.key, required this.volumeController, required this.priceController, this.fullTankText});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final displayText = fullTankText ?? S.of(context).full_tank;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: volumeController,
              builder: (context, value, child) {
                final liters = double.tryParse(value.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0;
                final total = (liters * price).toStringAsFixed(0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).sum, style: textTheme.bodySmall?.copyWith(color: AppColors.black87)),
                    Builder(
                      builder: (context) {
                        final settingsCubit = context.watch<SettingsCubit>();
                        final currencyLabel = settingsCubit.getCurrencyLabel(context, settingsCubit.state.currency);

                        return Text(
                          "$total $currencyLabel",
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          AppSpacers.horizontalMassive,
          GestureDetector(
            onTap: () {
              volumeController.text = "53";
            },
            child: Row(
              children: [
                const Icon(Icons.water_drop_outlined, color: AppColors.blue700),
                AppSpacers.horizontalSmallMedium,
                Text(
                  displayText,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
