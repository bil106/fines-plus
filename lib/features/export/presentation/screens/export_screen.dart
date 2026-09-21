// ignore_for_file: unused_element_parameter

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/share_helpers.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/features/export/presentation/widgets/export_card.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/export/data/datasources/export/export_history_csv.dart';
import 'package:fines_plus/features/export/data/datasources/export/export_history_pdf.dart';
import 'package:fines_plus/features/export/data/repository/export_repository.dart';
import 'package:fines_plus/features/export/data/repository/injector.dart';
import 'package:fines_plus/features/export/presentation/cubit/export_cubit.dart';
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
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        leading: AppBackButton(onPressed: onBack),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(S.of(context).export_history, style: textTheme.title),
                  AppSpacers.verticalXXLarge,
            
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
                        onTap: () => ShareHelpers.shareCsv(context,history),
                      ),
                    ],
                  ),
            
                  AppSpacers.verticalMaxMassive,
                  const AdBannerWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
