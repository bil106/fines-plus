import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// Round outlined "X" in the header of a bottom sheet. Closes the sheet,
/// which iPhones otherwise can only do with a swipe or a tap on the scrim.
class AppSheetCloseButton extends StatelessWidget {
  const AppSheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 14),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.neutreBlanc,
        side: BorderSide(color: context.brandTheme.surfaceBorder),
        shape: const CircleBorder(),
        minimumSize: const Size(30, 30),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }
}
