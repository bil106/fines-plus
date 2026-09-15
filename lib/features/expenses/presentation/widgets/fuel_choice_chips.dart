import 'package:flutter/material.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:design_system/colors/app_colors.dart';

class FuelChoiceChips extends StatelessWidget {
  final List<FuelType> fuels;
  final FuelType selectedFuel;
  final ValueChanged<FuelType> onSelected;

  const FuelChoiceChips({super.key, required this.fuels, required this.selectedFuel, required this.onSelected});

  static String _label(FuelType fuel) {
    switch (fuel) {
      case FuelType.Ai98:
        return '98';
      case FuelType.Ai95Plus:
        return '95+';
      case FuelType.Ai95:
        return '95';
      case FuelType.Ai92:
        return '92';
      case FuelType.LPG:
        return 'LPG';
      case FuelType.DIESEl:
        return 'DIESEL';
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
            _label(fuel),
            style: TextStyle(
              color: isSelected ? AppColors.neutreBlanc : AppColors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.blue700,
          backgroundColor: AppColors.grey300,
          onSelected: (_) => onSelected(fuel),
          checkmarkColor: AppColors.neutreBlanc,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }
}
