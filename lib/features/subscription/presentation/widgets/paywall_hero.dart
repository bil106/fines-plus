import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/paywall_image.dart';
import 'package:flutter/material.dart';

/// Dark, brand-tinted header of the paywall: the hero photo under a gradient,
/// brand name, headline, subtitle and three floating feature chips. [dark]
/// and [accent] come from the flavor's primary color.
class PaywallHero extends StatelessWidget {
  static const double _minHeight = 280;
  static const double _chipSize = 44;
  static const double _chipInset = 16;
  static const double _sidePadding = 22;
  static const List<(String, double, double)> _chips = [
    ('assets/images/paywall/icon_shield.png', _chipInset, 96),
    ('assets/images/paywall/icon_analytics.png', 30, 146),
    ('assets/images/paywall/icon_scan.png', _chipInset, 196),
  ];

  final Color dark;
  final Color accent;
  final double hueShift;
  final String heroAsset;
  final String brandName;
  final String headline;
  final String subtitle;
  final Widget? leading;

  /// How far the sheet below is pulled up over this header's bottom edge.
  final double sheetOverlap;

  const PaywallHero({
    super.key,
    required this.dark,
    required this.accent,
    required this.hueShift,
    required this.heroAsset,
    required this.brandName,
    required this.headline,
    required this.subtitle,
    required this.sheetOverlap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final textWidth = MediaQuery.sizeOf(context).width - _sidePadding - _chipSize - _chipInset - 12;
    final headlineStyle = context.brandTheme.displayTextStyle.copyWith(
      fontSize: 34,
      height: 1,
      fontWeight: FontWeight.w800,
      color: AppColors.neutreBlanc,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: dark,
            child: PaywallImage(
              asset: heroAsset,
              hueShift: hueShift,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [dark.withValues(alpha: 0.78), dark.withValues(alpha: 0.5), dark.withValues(alpha: 0)],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
        ),
        for (final chip in _chips)
          Positioned(
            right: chip.$2,
            top: topInset + chip.$3,
            child: Container(
              width: _chipSize,
              height: _chipSize,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.neutreBlanc.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutreBlanc.withValues(alpha: 0.14)),
              ),
              child: PaywallImage(asset: chip.$1, hueShift: hueShift),
            ),
          ),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: _minHeight + topInset),
          padding: EdgeInsets.fromLTRB(_sidePadding, topInset + 8, _sidePadding, sheetOverlap + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    if (leading != null) ...[leading!, AppSpacers.horizontalMedium],
                    Text(
                      brandName.toUpperCase(),
                      style: context.brandTheme.displayTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color.lerp(accent, AppColors.neutreBlanc, 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacers.verticalSmall,
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: textWidth),
                child: Text(headline.toUpperCase(), style: headlineStyle),
              ),
              AppSpacers.verticalSmallMedium,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 230),
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.neutreBlanc),
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ],
    );
  }
}
