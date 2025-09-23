import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              padding: const EdgeInsets.all(8),
              child: customIcon ?? Icon(icon, color: iconColor, size: 24),
            ),
            Container(width: 2, height: 80, color: AppColors.grey700),
          ],
        ),
        AppSpacers.horizontalMedium,
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutreGrey),
                    ),
                  ),
                  if (subtitle.isNotEmpty) Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  AppSpacers.verticalXSmall,
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacers.verticalSmallMedium,
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      AppSpacers.horizontalXSmall,
                      Text("${amount.toStringAsFixed(0)} ${S.of(context).grn}"),
                      AppSpacers.horizontalMediumLarge,
                      const Icon(Icons.directions_car, size: 16),
                      AppSpacers.horizontalXSmall,
                      Text(mileage),
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
