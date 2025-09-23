import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/core/widgets/time_line_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatelessWidget {
  final List<EventModel> events;

  const HistoryTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupEventsByMonth(events).entries.map((entry) {
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
                  date: event.date,
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
    final inputFormat = DateFormat('dd.MM.yyyy');
    final outputFormat = DateFormat('MMMM yyyy', 'uk');
    final groupedEvents = <String, List<EventModel>>{};

    for (final event in events) {
      DateTime? parsedDate;

      try {
        parsedDate = inputFormat.parse(event.date);
      } catch (_) {
        continue;
      }

      final key = outputFormat.format(parsedDate);

      groupedEvents.putIfAbsent(key, () => []);
      groupedEvents[key]!.add(event);
    }

    for (final group in groupedEvents.values) {
      group.sort((a, b) {
        final dateA = inputFormat.parse(a.date);
        final dateB = inputFormat.parse(b.date);
        return dateB.compareTo(dateA);
      });
    }

    return groupedEvents;
  }
}
