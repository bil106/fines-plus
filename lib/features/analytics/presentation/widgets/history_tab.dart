
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/analytics/presentation/widgets/time_line_item.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatelessWidget {
  final List<EventModel> events;

  const HistoryTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final grouped = groupEventsByMonth(events);

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
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: AppColors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: AppColors.neutreGrey),
                    ],
                  ),
                ),
              ),
              ...entry.value.map(
                (event) => TimelineItem(
                  icon: event.icon,
                  iconColor: event.iconColor,
                  customIcon: event.customIcon,
                  date: DateFormat('dd.MM.yyyy').format(event.date),
                  title: event.title,
                  subtitle: '',
                  amount: event.amount,
                  mileage: event.mileage,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Map<String, List<EventModel>> groupEventsByMonth(List<EventModel> events) {
    final outputFormat = DateFormat('MMMM yyyy', 'uk');

    final grouped = <String, List<EventModel>>{};

    for (final event in events) {
      final key = outputFormat.format(event.date);

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(event);
    }

    
    for (final group in grouped.values) {
      group.sort((a, b) => b.date.compareTo(a.date));
    }

    return grouped;
  }
}

