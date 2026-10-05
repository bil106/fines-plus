import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/paywall_image.dart';
import 'package:flutter/material.dart';

/// What the subscription includes, shared by every plan. The fines row only
/// shows for flavors/markets where the fines check exists.
class PaywallFeatureList extends StatelessWidget {
  static const String _iconsDir = 'assets/images/paywall/';

  final Color accent;
  final double hueShift;
  final bool showFines;

  const PaywallFeatureList({
    super.key,
    required this.accent,
    required this.hueShift,
    required this.showFines,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final features = <(String, String)>[
      if (showFines) ('icon_shield', s.paywall_feature_fines),
      ('icon_scan', s.paywall_feature_scan),
      ('icon_fuel', s.paywall_feature_fuel),
      if (showFines)
        ('icon_service', s.paywall_feature_service_reminders)
      else ...[
        ('icon_service', s.paywall_feature_service),
        ('icon_shield', s.paywall_feature_documents),
      ],
      ('icon_analytics', s.paywall_feature_stats),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radius18,
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          for (final feature in features)
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 22,
                    child: PaywallImage(asset: '$_iconsDir${feature.$1}.png', hueShift: hueShift),
                  ),
                  AppSpacers.horizontalMedium,
                  Expanded(
                    child: Text(
                      feature.$2,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ),
                  Icon(Icons.check, size: 16, color: accent),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
