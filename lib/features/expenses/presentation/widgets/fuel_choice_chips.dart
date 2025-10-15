import 'package:flutter/material.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:design_system/colors/app_colors.dart';

class FuelChoiceChips extends StatelessWidget {
  final List<FuelType> fuels;
  final FuelType selectedFuel;
  final ValueChanged<FuelType> onSelected;

  const FuelChoiceChips({super.key, required this.fuels, required this.selectedFuel, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: fuels.map((fuel) {
        final isSelected = fuel == selectedFuel;
        return ChoiceChip(
          label: Text(
            fuel.name.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.black87, 
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.blue700, 
          backgroundColor: AppColors.grey300, 
          onSelected: (_) => onSelected(fuel),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }
}
