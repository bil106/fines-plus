import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// A Ukrainian-style licence plate: silver frame, blue "UA" strip with the
/// flag, dark text on a white field - drawn on the dashboard hero card.
class LicensePlateBadge extends StatelessWidget {
  final String number;

  const LicensePlateBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: AppBorders.radiusMedium,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.plateFrameLight,
            AppColors.plateFrameMid,
            AppColors.plateFrameDark,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.plateInk.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppBorders.radiusSmall,
          border: Border.all(
            color: AppColors.plateInk,
            width: AppBorders.widthMedium,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.neutreBlanc, AppColors.plateSurfaceShade],
          ),
        ),
        child: ClipRRect(
          borderRadius: AppBorders.radiusSmall,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CountryStrip(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 2, 11, 2),
                  child: Text(
                    _formatPlate(number),
                    maxLines: 1,
                    style: context.brandTheme.displayTextStyle.copyWith(
                      color: AppColors.plateInk,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "AA1234BB" -> "AA 1234 BB", the way a standard Ukrainian plate is
/// spaced; any other format (custom plates, foreign cars) is left as typed.
String _formatPlate(String raw) {
  final plate = raw.replaceAll(' ', '').toUpperCase();
  final isStandard =
      plate.length == 8 && int.tryParse(plate.substring(2, 6)) != null;
  if (!isStandard) return raw.toUpperCase();
  return '${plate.substring(0, 2)} ${plate.substring(2, 6)} ${plate.substring(6)}';
}

class _CountryStrip extends StatelessWidget {
  const _CountryStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.plateStripTop, AppColors.plateStripBottom],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 12,
            height: 9,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutreBlanc, width: 0.75),
            ),
            child: const Column(
              children: [
                Expanded(child: ColoredBox(color: AppColors.plateFlagBlue)),
                Expanded(child: ColoredBox(color: AppColors.plateFlagYellow)),
              ],
            ),
          ),
          Text(
            'UA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutreBlanc,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
