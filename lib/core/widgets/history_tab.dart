import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/widgets/time_line_item.dart';
import 'package:flutter/material.dart';

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
                        ).textTheme.titleMedium?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                ),
              ),
              ...entry.value.map(
                (event) => TimelineItem(
                  icon: event.icon,
                  iconColor: event.iconColor,
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
    events.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<EventModel>> grouped = {};
    for (var event in events) {
      final key = event.date; 
      grouped.putIfAbsent(key, () => []).add(event);
    }
    return grouped;
  }
}
