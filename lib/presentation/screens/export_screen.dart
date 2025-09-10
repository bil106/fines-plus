// ignore_for_file: unused_element_parameter

import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/export/export_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/export_repository.dart';
import 'package:core_repository/injector.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ExportScreen extends StatelessWidget {
  final List<CarHistory> history;
  final String carNumber;
  final VoidCallback? onBack;
  const ExportScreen({super.key, required this.history, this.onBack, required this.carNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(exportPdf: getIt<ExportHistoryPdf>(), exportCsv: getIt<ExportHistoryCsv>()),
      child: _ExportScreenView(history: history, carNumber: carNumber),
    );
  }
}

class _ExportScreenView extends StatelessWidget {
  final List<CarHistory> history;
  final String carNumber;
  final VoidCallback? onBack;
  const _ExportScreenView({required this.history, this.onBack, required this.carNumber});

  Future<String> _loadCarNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('carNumber') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExportCubit>();
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<String>(
      future: _loadCarNumber(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final carNumber = snapshot.data!;

        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            backgroundColor: AppColors.grey50,
            leading: BackButton(
              color: AppColors.blue700,
              onPressed:
                  onBack ??
                  () {
                    final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                    homeState?.openPage(HomePage.analytics);
                  },
            ),
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
                    _ExportCard(
                      icon: Icons.picture_as_pdf,
                      label: S.of(context).pdf,
                      onTap: () => cubit.exportAsPdf(carNumber, history),
                    ),
                    _ExportCard(
                      icon: Icons.table_chart,
                      label: S.of(context).csv,
                      onTap: () => cubit.exportAsCsv(carNumber, history),
                    ),
                  ],
                ),
                AppSpacers.verticalMaxMassive,
                const AdBannerWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutreGreyLight, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 70, color: Colors.blue.shade700),
                const SizedBox(height: 8),
                Text(label, style: textTheme.historyText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
