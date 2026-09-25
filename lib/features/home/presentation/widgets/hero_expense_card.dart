// ignore_for_file: implementation_imports

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/helpers/statistics_costs_presenter.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/localization/flutter_stats_localization.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:design_system/theme/app_brand_theme.dart';

import 'hero_car_photo.dart';
import 'license_plate_badge.dart';

/// The dashboard's headline card: the active car (make/model, plate,
/// odometer, photo) on a dark brand-tinted surface, with this month's
/// expenses, the delta vs. last month, fuel consumption and cost per km.
///
/// Tapping the plate or the photo calls [onGarageTap]; the rest of the card
/// is left to the caller's own tap handler.
class HeroExpenseCard extends StatelessWidget {
  final bool hasCar;
  final StatisticsState state;
  final MainStats stats;
  final VoidCallback onGarageTap;

  const HeroExpenseCard({
    super.key,
    required this.hasCar,
    required this.state,
    required this.stats,
    required this.onGarageTap,
  });

  static const _photoWidth = 220.0;
  static const _photoHeight = 135.0;

  /// Card width on a Pixel 10 (412dp screen minus the dashboard's 8dp side
  /// padding) - the layout every screen is tuned to.
  static const _referenceWidth = 396.0;

  /// Narrower screens lay the card out at [_referenceWidth] and scale the
  /// whole thing down to fit, so small phones get the same proportions
  /// instead of the same pixel sizes squeezed into less room.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card = _buildCard(context);
        if (constraints.maxWidth >= _referenceWidth) return card;
        return FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          child: SizedBox(width: _referenceWidth, child: card),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brand = context.brandTheme;
    final currencyService = context.read<CurrencyService>();
    final settingsCubit = context.watch<SettingsCubit>();
    final currency = settingsCubit.state.currency;
    final unitStream = UnitStream(settingsCubit);
    final muted = AppColors.neutreBlanc.withValues(alpha: 0.72);

    final carNumber = context.watch<CarCubit>().state.carNumber;
    final garageState = context.watch<GarageCubit>().state;
    final activeCar = garageState.cars
        .where((car) => car.carId == garageState.activeCarId)
        .firstOrNull;
    final makeModel = [
      activeCar?.make ?? '',
      activeCar?.model ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');

    final presenter = StatisticsCostsPresenter(
      state: state,
      loc: FlutterStatsLocalization(S.of(context)),
      currency: currency,
      currencyService: currencyService,
    );

    final current = state.expenseStats.total;
    final previous = state.previousExpenseStats.total;
    final deltaPercent = previous > 0
        ? ((current - previous) / previous * 100)
        : null;

    final isMiles = settingsCubit.state.unit == 'mil';
    // stats.costPerKm is per km; a mile is longer, so it costs more per mile.
    final costPerKmConverted = currencyService.convert(
      isMiles ? stats.costPerKm / 0.621371 : stats.costPerKm,
      currency,
      fromCurrency: S.of(context).grn,
    );
    final mileageUnit = isMiles ? 'mil' : S.of(context).km;
    final fuelValue = unitStream.convertFuel(stats.averageFuelConsumption);
    final fuelUnit = settingsCubit.state.fuelConsumptionUnit == 'l/100km'
        ? "l/100${S.of(context).km}"
        : "mpg";

    return ClipRRect(
      borderRadius: AppBorders.radius22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [brand.heroBgStart, brand.heroBgMid, brand.heroBgEnd],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, -1),
                    radius: 0.9,
                    colors: [
                      brand.heroGlow.withValues(alpha: 0.33),
                      brand.heroGlow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onGarageTap,
                child: HeroCarPhoto(
                  photoUrl: activeCar?.photoUrl ?? '',
                  width: _photoWidth,
                  height: _photoHeight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (makeModel.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: _photoWidth - 30),
                      child: Text(
                        makeModel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        // Loaded as the brand body font's real ExtraBold
                        // file - a copyWith(fontWeight:) on the theme style
                        // would only synthesize bold from the regular one.
                        style: GoogleFonts.getFont(
                          context.read<AppConfig>().bodyFontFamily,
                          textStyle: textTheme.titleLarge,
                          color: AppColors.neutreBlanc,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onGarageTap,
                    child: carNumber.isNotEmpty
                        ? LicensePlateBadge(number: carNumber)
                        : Padding(
                            padding: const EdgeInsets.only(
                              right: _photoWidth - 30,
                            ),
                            child: Text(
                              S.of(context).input_number,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.neutreBlanc,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                  if (hasCar && stats.lastOdometer > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed, size: 16, color: muted),
                        const SizedBox(width: 10),
                        Text(
                          '${unitStream.convert(stats.lastOdometer.toDouble()).toStringAsFixed(0)} $mileageUnit',
                          style: textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).monthly_expenses,
                              style: textTheme.bodyMedium?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      hasCar ? presenter.currentFormatted : "0",
                                      // Brand money font (tabular mono
                                      // figures by default), per-flavor via
                                      // AppConfig.monoFontFamily.
                                      style: textTheme.headlineMedium
                                          ?.merge(brand.moneyTextStyle)
                                          .copyWith(
                                            color: AppColors.neutreBlanc,
                                            fontSize: 38,
                                            height: 1.05,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currency,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (hasCar && deltaPercent != null) ...[
                              const SizedBox(height: 4),
                              _DeltaLine(deltaPercent: deltaPercent),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _FuelPanel(
                        fuelValue: fuelValue.toStringAsFixed(1),
                        fuelUnit: fuelUnit,
                        costPerKm: costPerKmConverted.toStringAsFixed(1),
                        costPerKmUnit: '$currency/$mileageUnit',
                      ),
                    ],
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

class _DeltaLine extends StatelessWidget {
  final double deltaPercent;

  const _DeltaLine({required this.deltaPercent});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDown = deltaPercent <= 0;
    final color = isDown ? AppColors.successOnDark : AppColors.dangerOnDark;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDown ? Icons.arrow_downward : Icons.arrow_upward,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 2),
            Text(
              '${deltaPercent.abs().toStringAsFixed(0)}%',
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          S.of(context).vs_previous_month,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.neutreBlanc.withValues(alpha: 0.72),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FuelPanel extends StatelessWidget {
  final String fuelValue;
  final String fuelUnit;
  final String costPerKm;
  final String costPerKmUnit;

  const _FuelPanel({
    required this.fuelValue,
    required this.fuelUnit,
    required this.costPerKm,
    required this.costPerKmUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: AppBorders.radiusLarge,
        color: AppColors.neutreBlanc.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.neutreBlanc.withValues(alpha: 0.12),
          width: AppBorders.widthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_gas_station,
            size: 26,
            color: AppColors.neutreBlanc,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelValue(value: fuelValue, unit: fuelUnit),
              const SizedBox(height: 6),
              _PanelValue(value: costPerKm, unit: costPerKmUnit),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelValue extends StatelessWidget {
  final String value;
  final String unit;

  const _PanelValue({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.neutreBlanc,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.neutreBlanc.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
