import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/analytics/presentation/widgets/time_line_item.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatelessWidget {
  final List<EventModel> events;

  const HistoryTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();
    final hasCar = context.watch<CarCubit>().state.carNumber.isNotEmpty;

    if (!hasCar || events.isEmpty) {
      return  Center(
        child: Text(
          'Поки немає історії',
          style: Theme.of(context).textTheme.black16bold)
        
      );
    }

    final grouped = groupEventsByMonth(events, settingsCubit.state.locale);
    final userCurrency = settingsCubit.state.currency;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppColors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Divider(color: AppColors.neutreGrey),
                    ],
                  ),
                ),
              ),
              ...entry.value.map((event) {
                final convertedAmount =
                    settingsCubit.convertFromUAH(event.amount);
                final currencyLabel = settingsCubit.getCurrencyLabel(
                  context,
                  userCurrency,
                );

                return TimelineItem(
                  icon: event.icon,
                  iconColor: event.iconColor,
                  customIcon: event.customIcon,
                  date:
                      DateFormat('dd.MM.yyyy').format(event.date),
                  title: event.title,
                  subtitle: '',
                  amount: convertedAmount,
                  currencyLabel: currencyLabel,
                  mileage: event.mileage,
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}


Map<String, List<EventModel>> groupEventsByMonth(List<EventModel> events, Locale locale) {
    final outputFormat = DateFormat('MMMM yyyy', locale.languageCode);

    final grouped = <String, List<EventModel>>{};

    for (final event in events) {
      final key = outputFormat.format(event.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(event);
    }

    for (final group in grouped.values) {
      group.sort((a, b) {
        final mileageA = int.tryParse(a.mileage.replaceAll(RegExp(r'\D'), '')) ?? 0;
        final mileageB = int.tryParse(b.mileage.replaceAll(RegExp(r'\D'), '')) ?? 0;

        final mileageCompare = mileageB.compareTo(mileageA);
        if (mileageCompare != 0) return mileageCompare;

        return b.date.compareTo(a.date);
      });
    }

    return grouped;
  }


