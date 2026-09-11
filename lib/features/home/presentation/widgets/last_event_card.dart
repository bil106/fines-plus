import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/home/domain/entities/last_event_ui_model.dart';
import 'package:fines_plus/features/settings/presentation/cubit/currency_stream.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LastEventCardAction extends StatelessWidget {
  final LastEventUiModel? event;
  final VoidCallback? onTap;
  final VoidCallback? onOpenEvents;

  const LastEventCardAction({super.key, this.event, this.onTap, this.onOpenEvents});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final carCubit = context.watch<CarCubit?>();
    final carNumber = carCubit?.state.carNumber ?? '';

    if (carNumber.isEmpty || event == null) {
      return _buildCard(
        child: Center(
          child: Text(S.of(context).no_recent_events, style: textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        ),
      );
    }

    final settingsCubit = context.watch<SettingsCubit?>();
    if (settingsCubit == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, textTheme),
            SizedBox(height: 4.h),
            Divider(height: 1.h),
            SizedBox(height: 6.h),
            _buildContent(context, textTheme, settingsCubit),
            SizedBox(height: 4.h),
            Center(
              child: TextButton(onPressed: onOpenEvents, child: Text(S.of(context).view_all_events)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    final date = event?.date ?? '';
    return Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).last_event,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(date, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, TextTheme textTheme, SettingsCubit settingsCubit) {
    final amountOriginal = event?.amountOriginal;
    final amountValue = event?.amountValue ?? 0.0;
    final mileage = event?.mileage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        event?.icon ?? const SizedBox.shrink(),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event?.description ?? '',
                style: textTheme.black18W400,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    StreamBuilder<double>(
                      stream: CurrencyStream(settingsCubit).convertedAmountStream(event!),
                      initialData: amountOriginal ?? amountValue,
                      builder: (context, snapshot) {
                        final convertedValue = snapshot.data ?? 0.0;
                        final currency = settingsCubit.getCurrencyLabel(context, settingsCubit.state.currency);
                        return Text(
                          "${convertedValue.toStringAsFixed(0)} $currency",
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blueAccent,
                          ),
                        );
                      },
                    ),

                    if (mileage != null) ...[
                      const SizedBox(width: 12),
                      Text("${mileage.toStringAsFixed(0)} ${settingsCubit.state.unit}", style: textTheme.black8718W400),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
