import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ServiceRecordCard extends StatelessWidget {
  final ServiceRecord record;
  const ServiceRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.build, size: 42, color: AppColors.blue700),
        title: Text(record.serviceName, style: textTheme.historyText),
        subtitle: Text("${record.date} • ${record.mileage} km", style: textTheme.subtitleText),
        trailing: Text("${record.cost.toStringAsFixed(0)} ₴", style: textTheme.subtitleText),
      ),
    );
  }
}
