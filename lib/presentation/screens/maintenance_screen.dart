// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/service_record_card.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MaintenanceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const MaintenanceScreen({super.key, this.onBack});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
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
            AppSpacers.verticalLargeXL,
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}
