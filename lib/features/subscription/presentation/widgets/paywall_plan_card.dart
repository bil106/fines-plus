import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One compact, selectable plan on the paywall. The headline figure is the
/// per-week price; the full billed price is the small [trialLine]. All text
/// is passed in already formatted by the screen, which owns the store prices.
class PaywallPlanCard extends StatelessWidget {
  final String title;
  final String weekPrice;
  final String trialLine;
  final bool isSelected;
  final bool isPopular;
  final bool adFree;
  final String? saveLabel;
  final Color accent;
  final VoidCallback onTap;

  const PaywallPlanCard({
    super.key,
    required this.title,
    required this.weekPrice,
    required this.trialLine,
    required this.isSelected,
    required this.isPopular,
    required this.adFree,
    required this.accent,
    required this.onTap,
    this.saveLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                color: isSelected ? Color.lerp(accent, AppColors.neutreBlanc, 0.92) : AppColors.neutreBlanc,
                borderRadius: AppBorders.radius18,
                border: Border.all(
                  color: isSelected ? accent : context.brandTheme.surfaceBorder,
                  width: isSelected ? AppBorders.widthThick : AppBorders.widthThin,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.black18bold.copyWith(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                  ),
                  AppSpacers.verticalXSmall,
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 4,
                    children: [
                      Text(
                        weekPrice,
                        maxLines: 1,
                        style: textTheme.black20bold
                            .merge(context.brandTheme.moneyTextStyle)
                            .copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          S.of(context).paywall_per_week_suffix,
                          style: textTheme.black13W400.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  AppSpacers.verticalXSmall,
                  Text(
                    trialLine,
                    style: textTheme.black13W400.copyWith(fontSize: 11, height: 1.3, color: AppColors.textSecondary),
                  ),
                  AppSpacers.verticalXSmall,
                  adFree
                      ? Row(
                          children: [
                            Icon(Icons.block, size: 14, color: accent),
                            AppSpacers.horizontalSmall,
                            Text(
                              S.of(context).paywall_feature_no_ads,
                              style: textTheme.black14bold.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: accent),
                            ),
                          ],
                        )
                      : Text(
                          S.of(context).paywall_contains_ads,
                          style: textTheme.black13W400.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.catOther),
                        ),
                  if (saveLabel != null) ...[
                    AppSpacers.verticalSmall,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 9),
                      decoration: BoxDecoration(
                        color: AppColors.neutreBlanc,
                        borderRadius: AppBorders.radius50,
                        border: Border.all(color: accent),
                      ),
                      child: Text(
                        saveLabel!,
                        maxLines: 1,
                        style: textTheme.black14bold.copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: accent),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? accent : AppColors.inactiveDot,
                size: 22,
              ),
            ),
            if (isPopular)
              Positioned(
                top: -11,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  decoration: BoxDecoration(color: accent, borderRadius: AppBorders.radius50),
                  child: Text(
                    S.of(context).most_popular,
                    style: textTheme.black14bold.copyWith(
                      color: AppColors.neutreBlanc,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
