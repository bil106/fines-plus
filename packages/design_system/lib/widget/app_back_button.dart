import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// Shared white, outlined back button with a grey chevron.
/// Pops the current route when [onPressed] is omitted.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 32,
        child: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onPressed ?? () => Navigator.maybePop(context),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.neutreBlanc,
            foregroundColor: AppColors.grey700,
            padding: EdgeInsets.zero,
            shape: CircleBorder(
              side: BorderSide(color: context.brandTheme.surfaceBorder),
            ),
          ),
          icon: const Icon(Icons.chevron_left, size: 16),
        ),
      ),
    );
  }
}
