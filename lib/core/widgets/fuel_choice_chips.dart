import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class FuelChoiceChips extends StatelessWidget {
  final List<String> fuels;
  final String selectedFuel;
  final ValueChanged<String> onSelected;

  const FuelChoiceChips({super.key, required this.fuels, required this.selectedFuel, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: fuels.map((fuel) {
        final isSelected = selectedFuel == fuel;
        return ChoiceChip(
          label: Text(fuel),
          selected: isSelected,
          selectedColor: AppColors.blue700,
          backgroundColor: AppColors.neutreBlanc,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          onSelected: (_) => onSelected(fuel),
          showCheckmark: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        );
      }).toList(),
    );
  }
}
