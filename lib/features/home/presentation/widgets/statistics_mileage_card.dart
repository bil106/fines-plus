import 'package:core_localization/generated/l10n.dart';
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

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final presenter = StatisticsMileagePresenter(state);

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).mileage_stat, style: textTheme.titleMedium),
              const Divider(height: 16, thickness: 1),

              _buildRow(presenter, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(StatisticsMileagePresenter presenter, BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();
    final unitStream = UnitStream(settingsCubit);
final carNumber = context.watch<CarCubit>().state.carNumber;
    final hasCar = carNumber.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/icons/steeringWheel.png', width: 36, height: 36, color: Colors.grey),
        const SizedBox(width: 8),

        StreamBuilder<double>(
          stream: unitStream.unitValueStream(presenter.mileageThisMonth.toDouble()),
          initialData: unitStream.convert(presenter.mileageThisMonth.toDouble()),
          builder: (context, snapshot) {
           final value = hasCar
                ? snapshot.data ?? presenter.mileageThisMonth.toDouble()
                : 0; 

            final unit = settingsCubit.state.unit;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${presenter.monthLabel} ${DateTime.now().year}", style: const TextStyle(color: Colors.black54)),
                Text(
                  "${value.toStringAsFixed(0)} $unit",
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            );
          },
        ),

        const Spacer(),

        Row(
          children: [
            presenter.arrowIcon,
            const SizedBox(width: 4),
            Column(
              children: [
                Text("${presenter.changePercent.abs()}%", style: TextStyle(color: presenter.changeColor, fontSize: 18)),
                Text(S.current.per_month, style: TextStyle(color: presenter.changeColor, fontSize: 18)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), child: child),
    );
  }
}
