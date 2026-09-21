import 'package:flutter/material.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:core_localization/generated/l10n.dart';

class FuelChoiceChips extends StatelessWidget {
  final List<FuelType> fuels;
  final FuelType selectedFuel;
  final ValueChanged<FuelType> onSelected;

  const FuelChoiceChips({super.key, required this.fuels, required this.selectedFuel, required this.onSelected});

  static String _label(BuildContext context, FuelType fuel) {
    switch (fuel) {
      case FuelType.Ai98:
        return '98';
      case FuelType.Ai95Plus:
        return '95+';
      case FuelType.Ai95:
        return S.of(context).fuel_chip_a95;
      case FuelType.Ai92:
        return S.of(context).fuel_chip_a92;
      case FuelType.LPG:
        return S.of(context).fuel_chip_gas;
      case FuelType.DIESEl:
        return S.of(context).fuel_chip_diesel;
      case FuelType.Electric:
        return S.of(context).fuel_electric;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: fuels.map((fuel) {
        final isSelected = fuel == selectedFuel;
        return ChoiceChip(
          label: Text(
            _label(context, fuel),
            style: TextStyle(
              color: isSelected ? AppColors.blue700 : AppColors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: AppColors.neutreBlanc,
          backgroundColor: AppColors.neutreBlanc,
          side: BorderSide(color: isSelected ? AppColors.blue700 : AppColors.grey300),
          onSelected: (_) => onSelected(fuel),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }
}
