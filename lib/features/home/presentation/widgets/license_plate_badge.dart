import 'dart:math' as math;

import 'package:core_utils/formatters/plate_market.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A licence plate in the brand market's style (AppConfig.market), drawn on
/// the dashboard hero card. All markets share the silver frame and white
/// field; UA gets the blue "UA" strip with the flag, ES the blue EU strip
/// with the stars and "E", US a navy "USA" header above the number.
class LicensePlateBadge extends StatelessWidget {
  final String number;

  const LicensePlateBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<AppConfig>().plateMarket;
    final ink = market == PlateMarket.us ? AppColors.plateUsInk : AppColors.plateInk;
    final numberText = Text(
      market.display(number),
      maxLines: 1,
      style: context.brandTheme.displayTextStyle.copyWith(
        color: ink,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        height: 1.1,
      ),
    );

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
            color: ink,
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
            child: market == PlateMarket.us
                ? _UsField(numberText: numberText)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      market == PlateMarket.es ? const _EuStrip() : const _UaStrip(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(9, 2, 11, 2),
                        child: numberText,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The blue strip on the left of UA/EU plates: an emblem on top, the
/// country code at the bottom.
class _CountryStrip extends StatelessWidget {
  final Color top;
  final Color bottom;
  final Widget emblem;
  final String code;

  const _CountryStrip({
    required this.top,
    required this.bottom,
    required this.emblem,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          emblem,
          Text(
            code,
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

class _UaStrip extends StatelessWidget {
  const _UaStrip();

  @override
  Widget build(BuildContext context) {
    return _CountryStrip(
      top: AppColors.plateStripTop,
      bottom: AppColors.plateStripBottom,
      code: 'UA',
      emblem: Container(
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
    );
  }
}

class _EuStrip extends StatelessWidget {
  const _EuStrip();

  @override
  Widget build(BuildContext context) {
    return const _CountryStrip(
      top: AppColors.plateEuStripTop,
      bottom: AppColors.plateEuStripBottom,
      code: 'E',
      emblem: SizedBox(
        width: 15,
        height: 15,
        child: CustomPaint(painter: _EuStarsPainter()),
      ),
    );
  }
}

/// The EU circle of 12 five-pointed stars.
class _EuStarsPainter extends CustomPainter {
  const _EuStarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.plateEuStar;
    final center = size.center(Offset.zero);
    final ringRadius = size.width * 0.40;
    final outer = size.width * 0.09;
    final inner = outer * 0.4;

    for (var star = 0; star < 12; star++) {
      final angle = star * math.pi / 6;
      final starCenter = center + Offset(math.sin(angle), -math.cos(angle)) * ringRadius;
      final path = Path();
      for (var point = 0; point < 10; point++) {
        final radius = point.isEven ? outer : inner;
        final pointAngle = point * math.pi / 5;
        final offset = starCenter + Offset(math.sin(pointAngle), -math.cos(pointAngle)) * radius;
        if (point == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      canvas.drawPath(path..close(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// US plates have no side strip - a small "USA" header sits above the
/// number instead.
class _UsField extends StatelessWidget {
  final Widget numberText;

  const _UsField({required this.numberText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'USA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.plateUsInk,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.4,
              height: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 3),
          child: numberText,
        ),
      ],
    );
  }
}
