import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget? customIcon;
  final String date;
  final String title;
  final String subtitle;
  final double amount;
  final String mileage;
  final String currencyLabel;

  const TimelineItem({
    super.key,
    required this.icon,
    required this.iconColor,
    this.customIcon,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.mileage,
    required this.currencyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: customIcon ?? Icon(icon, color: iconColor, size: 24),
            ),
            Container(
              width: 2,
              height: 60,
              color: context.brandTheme.surfaceBorder,
            ),
          ],
        ),
        AppSpacers.horizontalMedium,
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.neutreBlanc,
              borderRadius: AppBorders.radius16,
              border: Border.all(color: context.brandTheme.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      date,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  AppSpacers.verticalXSmall,
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  AppSpacers.verticalSmallMedium,
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      AppSpacers.horizontalXSmall,
                      Text(
                        "${amount.toStringAsFixed(0)} $currencyLabel",
                        style: textTheme.bodySmall
                            ?.merge(context.brandTheme.moneyTextStyle)
                            .copyWith(fontSize: 13, color: AppColors.ink),
                      ),
                      AppSpacers.horizontalMediumLarge,
                      Icon(
                        Icons.directions_car,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      AppSpacers.horizontalXSmall,
                      Text(
                        mileage,
                        style: textTheme.bodySmall
                            ?.merge(context.brandTheme.moneyTextStyle)
                            .copyWith(fontSize: 13, color: AppColors.ink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
