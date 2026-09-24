import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// The white, bordered, rounded container shared by the dashboard's content
/// cards ("Витрати" chart, "Останні операції"), so they stay identical.
class DashboardCard extends StatelessWidget {
  final Widget child;

  const DashboardCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radius16,
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      child: child,
    );
  }
}
