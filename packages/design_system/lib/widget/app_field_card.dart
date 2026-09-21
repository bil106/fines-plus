import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:flutter/material.dart';

/// A form field's shared "flat card" look across the quick-add sheets
/// (Паливо/ТО/Страхування/...): a thin bordered white box with a small
/// grey label always visible above the field, instead of a floating
/// Material label. [child] is typically a borderless TextField.
class AppFieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  const AppFieldCard({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radiusMedium,
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.black87)),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
