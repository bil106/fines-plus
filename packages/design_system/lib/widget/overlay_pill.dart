import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:flutter/material.dart';

/// Rounded status pill used by the scan overlays: a [leading] visual, a bold
/// [title] and a smaller [subtitle].
class OverlayPill extends StatelessWidget {
  const OverlayPill({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.background = AppColors.ink,
    this.foreground = AppColors.neutreBlanc,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppBorders.radius50,
        boxShadow: const [
          BoxShadow(color: AppColors.black26, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            AppSpacers.horizontalMedium,
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(color: foreground, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(color: foreground.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
