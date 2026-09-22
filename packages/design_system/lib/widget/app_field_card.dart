import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// A form field's shared "flat card" look across the quick-add sheets
/// (Паливо/ТО/Страхування/...): a thin bordered white box with a small
/// grey label always visible above the field, instead of a floating
/// Material label. [child] is typically a borderless TextField.
const _accentWashAlpha = 0.18;
const _accentBorderWidth = 1.5;

class AppFieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  /// Draws attention to the field (e.g. an expiry date that is near or past):
  /// coloured border and a light wash of the same colour.
  final Color? accent;

  const AppFieldCard({super.key, required this.label, required this.child, this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: accent == null
            ? AppColors.neutreBlanc
            : Color.alphaBlend(accent!.withValues(alpha: _accentWashAlpha), AppColors.neutreBlanc),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: accent ?? context.brandTheme.surfaceBorder,
            width: accent == null ? 1 : _accentBorderWidth,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11.5)),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
