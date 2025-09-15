// ignore_for_file: unused_element_parameter

import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/export/export_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/export_repository.dart';
import 'package:core_repository/injector.dart';
import 'package:core_utils/share_helpers.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/export_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@RoutePage()
class ExportScreen extends StatelessWidget {
  final List<EventModel> history;
  final String carNumber;
  final VoidCallback? onBack;

  const ExportScreen({super.key, required this.history, required this.carNumber, this.onBack});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(
        exportRepository: getIt<ExportRepositoryImpl>(),
        exportPdf: getIt<ExportHistoryPdf>(),
        exportCsv: getIt<ExportHistoryCsv>(),
      ),
      child: _ExportScreenView(history: history, carNumber: carNumber, onBack: onBack ?? () {}),
    );
  }
}

class _ExportScreenView extends StatelessWidget {
  final List<EventModel> history;
  final String carNumber;
  final VoidCallback? onBack;

  const _ExportScreenView({required this.history, required this.carNumber, this.onBack});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: onBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.of(context).export_history, style: textTheme.title),
            AppSpacers.verticalXXLarge,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(carNumber, style: textTheme.historyText),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ExportCard(
                  icon: Icons.picture_as_pdf,
                  label: S.of(context).pdf,
                  onTap: () => ShareHelpers.sharePdf(context, carNumber, history),
                ),
                ExportCard(
                  icon: Icons.table_chart,
                  label: S.of(context).csv,
                  onTap: () => ShareHelpers.shareCsv(context, carNumber, history),
                ),
              ],
            ),

            AppSpacers.verticalMaxMassive,
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}
