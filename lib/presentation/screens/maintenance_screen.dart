import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/service_record_card.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MaintenanceScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const MaintenanceScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: onBack ?? () {}),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ТО", style: textTheme.title),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: mockServiceHistory.length,
                itemBuilder: (context, index) {
                  return ServiceRecordCard(record: mockServiceHistory[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

