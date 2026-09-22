import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// A compact pill toggle matching the Fines+OS mockup's switch (40x24 track,
/// 18px thumb) - the stock Material [Switch] renders noticeably taller and
/// doesn't match the design.
class AppToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;

  const AppToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 45,
    this.height = 20,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    const padding = 3.0;
    final thumbSize = height - (padding * 2);
    final active = activeTrackColor ?? Theme.of(context).colorScheme.primary;
    final inactive = inactiveTrackColor ?? context.brandTheme.surfaceBorder;
    final thumb = thumbColor ?? AppColors.neutreBlanc;

    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value ? active : inactive,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? (width - thumbSize - padding) : padding,
              top: padding,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: thumb,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
