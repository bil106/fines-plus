import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:flutter/material.dart';

class FuelAmountCard extends StatelessWidget {
  final TextEditingController controller;
  final int price;
  final String fullTankText;

  const FuelAmountCard({super.key, required this.controller, required this.price, this.fullTankText = "Full tank"});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radiusLarge,
        border: Border.all(color: AppColors.grey300, width: 2.0),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, color: AppColors.blue700),
          AppSpacers.horizontalSmallMedium,

          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final liters = double.tryParse(value.text) ?? 0;
                final total = (liters * price).toStringAsFixed(2);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).sum, style: textTheme.bodySmall?.copyWith(color: AppColors.black87)),
                    Text(
                      "$total ${S.of(context).grn}",
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                    ),
                  ],
                );
              },
            ),
          ),

          AppSpacers.horizontalMassive,

          GestureDetector(
            onTap: () {
              controller.text = "53";
            },
            child: Row(
              children: [
                Icon(Icons.water_drop_outlined, color: AppColors.blue700),
                AppSpacers.horizontalSmallMedium,
                Text(
                  fullTankText,
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
