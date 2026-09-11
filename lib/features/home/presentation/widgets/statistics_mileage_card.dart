import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/core/helpers/statistics_mileage_presenter%20.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsMileageCard extends StatelessWidget {
  const StatisticsMileageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasCar = context.watch<CarCubit>().state.carNumber.isNotEmpty;
    final settingsCubit = context.watch<SettingsCubit>();
    final unitStream = UnitStream(settingsCubit);

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final presenter = StatisticsMileagePresenter(state);
        final unit = settingsCubit.state.unit;

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).mileage_stat, style: textTheme.titleMedium),
              const Divider(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/icons/steeringWheel.png', width: 36, height: 36, color: Colors.grey),
                  const SizedBox(width: 12),

                  Expanded(
                    child: StreamBuilder<double>(
                      stream: unitStream.unitValueStream(presenter.mileageThisMonth.toDouble()),
                      initialData: unitStream.convert(presenter.mileageThisMonth.toDouble()),
                      builder: (context, snapshot) {
                        final value = hasCar ? snapshot.data ?? 0.0 : 0.0;
                        return _AmountBlock(
                          label: "${presenter.monthLabel} ${DateTime.now().year}",
                          amount: value.toStringAsFixed(0),
                          unit: unit,
                          color: AppColors.blueAccent,
                          valueStyle: textTheme.titleLarge,
                        );
                      },
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      presenter.arrowIcon,
                      const SizedBox(width: 6),
                      _AmountBlock(
                        label: S.current.per_month,
                        amount: "${presenter.changePercent.abs()}%",
                        unit: "",
                        color: presenter.changeColor,
                        valueStyle: textTheme.titleMedium,
                        alignEnd: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14), child: child),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  final String label;
  final String amount;
  final String unit;
  final Color color;
  final TextStyle? valueStyle;
  final bool alignEnd;

  const _AmountBlock({
    required this.label,
    required this.amount,
    required this.unit,
    required this.color,
    this.valueStyle,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "$amount $unit".trim(),
            maxLines: 1,
            style: valueStyle?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
