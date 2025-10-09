import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:flutter/material.dart';

class FuelInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FuelType fuel;

  const FuelInputCard({super.key, required this.controller, required this.fuel});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final price = fuelPrices[fuel] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radiusLarge,
        border: Border.all(color: AppColors.grey300, width: 2.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station, color: AppColors.blue700),
          AppSpacers.horizontalSmallMedium,
          Expanded(
            child: TextField(
              controller: controller,
              showCursor: false,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0 L",
              ),
            ),
          ),
          AppSpacers.horizontalMassive,
          const Icon(Icons.monetization_on_outlined, color: AppColors.blue700),
          AppSpacers.horizontalSmallMedium,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).price_liter, style: textTheme.bodySmall?.copyWith(color: AppColors.black87)),
              Text(
                "$price ${S.of(context).grn}",
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
