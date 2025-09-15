import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FuelRecordCard extends StatelessWidget {
  final FuelRecord record;
  const FuelRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.local_gas_station, color: Colors.redAccent, size: 50),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text("${record.fuelType} / ${record.volume}L", style: textTheme.historyText),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 8),
                    Text("${record.cost} ${S.of(context).grn}", style: textTheme.subtitleText),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(record.date, style: textTheme.subtitleText),
                    const SizedBox(width: 28),
                    Icon(Icons.speed, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("${record.mileage} ${S.of(context).km}", style: textTheme.subtitleText),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
