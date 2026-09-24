import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/analytics/presentation/widgets/history_tab.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// "Історія" bottom-nav tab: every expense grouped by month, with the
/// export action in the header. Replaces the History tab of the (now hidden)
/// Analytics screen, reading MaintenanceCubit live so new records - including
/// insurance and "other" expenses - show up without reopening the page.
class ExpenseHistoryScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ExpenseHistoryScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MaintenanceCubit, MaintenanceState>(
      builder: (context, state) {
        final events = _buildEvents(context, state);

        return Scaffold(
          backgroundColor: context.brandTheme.surfaceBg,
          appBar: AppBar(
            backgroundColor: context.brandTheme.surfaceBg,
            automaticallyImplyLeading: false,
            leading: onBack == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: AppBackButton(onPressed: onBack),
                  ),
            leadingWidth: onBack == null ? null : 68,
            surfaceTintColor: AppColors.transparent,
            elevation: 0,
            toolbarHeight: 72,
            titleSpacing: onBack == null ? 20 : 12,
            actionsPadding: const EdgeInsets.only(right: 20),
            title: Text(
              S.of(context).history,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            actions: [
              IconButton(
                tooltip: S.of(context).export,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: AppColors.neutreBlanc,
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.upload, size: 20),
                onPressed: () {
                  final homeState = context
                      .findAncestorStateOfType<HomeScreenWrapperState>();
                  // ExportScreen reads the list when the wrapper rebuilds
                  // on openPage, so hand it the current one right before.
                  homeState?.exportHistory = events;
                  homeState?.openPage(HomePage.export);
                },
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HistoryTab(events: events),
            ),
          ),
        );
      },
    );
  }
}

/// All expense records as timeline events, newest first, amounts in the
/// base currency (HistoryTab converts to the user's currency).
List<EventModel> _buildEvents(BuildContext context, MaintenanceState state) {
  final s = S.of(context);
  final currencyService = context.read<CurrencyService>();
  final isMiles = context.read<SettingsCubit>().state.unit == 'mil';

  double toBase(double amount, String? currency) => currencyService.convert(
    amount,
    s.grn,
    fromCurrency: currency ?? s.grn,
  );

  String mileage(int? value) {
    if (value == null || value <= 0) return '';
    return isMiles
        ? '${(value * 0.621371).toStringAsFixed(0)} mil'
        : '$value ${s.km}';
  }

  final events = <EventModel>[
    for (final r in state.fuelRecords)
      EventModel(
        date: r.date,
        title:
            '${fuelTypeLabel(context, r.fuelType)} / ${r.volume} ${fuelUnitLabel(context, r.fuelType)}',
        amount: toBase(r.cost, r.currency),
        mileage: mileage(r.mileage),
        iconCodePoint: Icons.local_gas_station.codePoint,
        iconColorValue: AppColors.catFuel.toARGB32(),
        category: ExpenseCategory.fuel,
      ),
    for (final r in state.serviceRecords)
      EventModel(
        date: _parseDdMmYyyy(r.date),
        title: r.serviceName,
        amount: toBase(r.cost, r.currency),
        mileage: mileage(r.mileage),
        iconCodePoint: Icons.build.codePoint,
        iconColorValue: AppColors.catService.toARGB32(),
        category: ExpenseCategory.service,
      ),
    for (final r in state.tuningRecords)
      EventModel(
        date: r.date,
        title: r.tuningName,
        amount: toBase(r.cost, r.currency),
        mileage: mileage(r.mileage),
        iconCodePoint: Icons.build_circle.codePoint,
        iconColorValue: AppColors.catTuning.toARGB32(),
        category: ExpenseCategory.tuning,
        customIcon: Image.asset(
          'assets/icons/tuning.jpg',
          height: 24,
          width: 24,
        ),
      ),
    for (final r in state.carWashRecords)
      EventModel(
        date: r.date,
        title: (r.comment?.isNotEmpty ?? false) ? r.comment! : s.car_wash,
        amount: toBase(r.amount, r.currency),
        mileage: mileage(r.mileage),
        iconCodePoint: Icons.local_car_wash.codePoint,
        iconColorValue: AppColors.catCarWash.toARGB32(),
        category: ExpenseCategory.carWash,
      ),
    for (final r in state.insuranceRecords)
      EventModel(
        date: r.validFrom,
        title: r.company.isNotEmpty ? r.company : s.insurance,
        amount: toBase(r.cost, r.currency),
        mileage: '',
        iconCodePoint: Icons.gpp_good.codePoint,
        iconColorValue: AppColors.catInsurance.toARGB32(),
        category: ExpenseCategory.insurance,
      ),
    for (final r in state.otherRecords)
      EventModel(
        date: r.date,
        title: (r.comment?.isNotEmpty ?? false) ? r.comment! : s.other,
        amount: toBase(r.cost, r.currency),
        mileage: mileage(r.mileage),
        iconCodePoint: Icons.more_horiz.codePoint,
        iconColorValue: AppColors.catOther.toARGB32(),
        category: ExpenseCategory.other,
      ),
  ];
  events.sort((a, b) => b.date.compareTo(a.date));
  return events;
}

DateTime _parseDdMmYyyy(String value) {
  try {
    return DateFormat('dd.MM.yyyy').parse(value);
  } catch (_) {
    return DateTime.now();
  }
}
