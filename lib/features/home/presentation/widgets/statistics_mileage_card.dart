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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              SizedBox(height: 8.h),
              Divider(height: 1.h),
              SizedBox(height: 8.h),
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
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/icons/steeringWheel.png', width: 36.w, height: 36.w, color: Colors.grey),

        SizedBox(width: 12.w),

    
        Expanded(
          child: StreamBuilder<double>(
            stream: unitStream.unitValueStream(presenter.mileageThisMonth.toDouble()),
            initialData: unitStream.convert(presenter.mileageThisMonth.toDouble()),
            builder: (context, snapshot) {
              final value = hasCar ? snapshot.data ?? presenter.mileageThisMonth.toDouble() : 0;

              final unit = settingsCubit.state.unit;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${presenter.monthLabel} ${DateTime.now().year}",
                    style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${value.toStringAsFixed(0)} $unit",
                    style: TextStyle(color: AppColors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(width: 12.w),

        
        Row(
          children: [
            presenter.arrowIcon,
            SizedBox(width: 4.w),
            Column(
              children: [
                Text(
                  "${presenter.changePercent.abs()}%",
                  style: TextStyle(color: presenter.changeColor, fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  S.current.per_month,
                  style: TextStyle(color: presenter.changeColor, fontSize: 14.sp),
                ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: child,
      ),
    );
  }
}
