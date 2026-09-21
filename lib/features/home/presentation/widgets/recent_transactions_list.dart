import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:intl/intl.dart';

const _kUkMonthsShort = [
  'січ', 'лют', 'бер', 'кві', 'тра', 'чер', 'лип', 'сер', 'вер', 'жов', 'лис', 'гру',
];

class _TxItem {
  final ExpenseCategory category;
  final String label;
  final DateTime date;
  final double amount;
  final String currency;
  final int? mileage;

  const _TxItem({
    required this.category,
    required this.label,
    required this.date,
    required this.amount,
    required this.currency,
    this.mileage,
  });
}

Color _categoryColor(ExpenseCategory c) {
  switch (c) {
    case ExpenseCategory.fuel:
      return AppColors.catFuel;
    case ExpenseCategory.service:
      return AppColors.catService;
    case ExpenseCategory.tuning:
      return AppColors.catTuning;
    case ExpenseCategory.carWash:
      return AppColors.catCarWash;
    case ExpenseCategory.insurance:
      return AppColors.catInsurance;
    case ExpenseCategory.other:
      return AppColors.catOther;
  }
}

String _categoryLabel(ExpenseCategory c, BuildContext context) {
  switch (c) {
    case ExpenseCategory.fuel:
      return S.of(context).fuel;
    case ExpenseCategory.service:
      return S.of(context).service;
    case ExpenseCategory.tuning:
      return S.of(context).tuning;
    case ExpenseCategory.carWash:
      return S.of(context).car_wash;
    case ExpenseCategory.insurance:
      return S.of(context).insurance;
    case ExpenseCategory.other:
      return S.of(context).other;
  }
}

List<_TxItem> _mergeRecords(MaintenanceState state) {
  final items = <_TxItem>[
    for (final r in state.fuelRecords)
      _TxItem(
        category: ExpenseCategory.fuel,
        label: r.fuelType,
        date: r.date,
        amount: r.cost,
        currency: r.currency,
        mileage: r.mileage,
      ),
    for (final r in state.serviceRecords)
      _TxItem(
        category: ExpenseCategory.service,
        label: r.serviceName,
        date: _parseDdMmYyyy(r.date),
        amount: r.cost,
        currency: r.currency,
        mileage: r.mileage,
      ),
    for (final r in state.carWashRecords)
      _TxItem(
        category: ExpenseCategory.carWash,
        label: (r.comment?.isNotEmpty ?? false) ? r.comment! : 'Car wash',
        date: r.date,
        amount: r.amount,
        currency: r.currency ?? 'UAH',
        mileage: r.mileage,
      ),
    for (final r in state.tuningRecords)
      _TxItem(
        category: ExpenseCategory.tuning,
        label: r.tuningName,
        date: r.date,
        amount: r.cost,
        currency: r.currency,
        mileage: r.mileage,
      ),
    for (final r in state.insuranceRecords)
      _TxItem(
        category: ExpenseCategory.insurance,
        label: r.company,
        date: r.validFrom,
        amount: r.cost,
        currency: r.currency,
      ),
    for (final r in state.otherRecords)
      _TxItem(
        category: ExpenseCategory.other,
        label: (r.comment?.isNotEmpty ?? false) ? r.comment! : 'Other',
        date: r.date,
        amount: r.cost,
        currency: r.currency,
        mileage: r.mileage,
      ),
  ];
  items.sort((a, b) {
    // These are all a user-chosen "date of service", not a save timestamp -
    // Service's date is always flattened to midnight (it round-trips
    // through a "dd.MM.yyyy" string), while Fuel's keeps a real
    // time-of-day whenever the date picker was never touched (it just
    // defaults to DateTime.now()). Comparing the raw DateTimes then made a
    // same-day fuel entry always outrank a same-day service entry added
    // later, since "14:32" > "00:00" even on the same calendar day.
    // Normalize to calendar-day first so same-day entries actually tie.
    final aDay = DateTime(a.date.year, a.date.month, a.date.day);
    final bDay = DateTime(b.date.year, b.date.month, b.date.day);
    final byDate = bDay.compareTo(aDay);
    if (byDate != 0) return byDate;
    // Odometer reading only goes up, so on a same-day tie it's the best
    // signal for which entry actually happened later.
    return (b.mileage ?? -1).compareTo(a.mileage ?? -1);
  });
  return items;
}

DateTime _parseDdMmYyyy(String value) {
  try {
    return DateFormat('dd.MM.yyyy').parse(value);
  } catch (_) {
    return DateTime.now();
  }
}

/// The dashboard's "recent transactions" list from the Fines+OS mockup -
/// merges the record streams MaintenanceCubit already tracks, newest first.
///
/// Insurance here means a purchased policy (InsuranceRecord, company/policy/
/// cost) - distinct from the older recurring renewal *reminder* still created
/// via InsuranceDetailSheet/QuickActionsCubit under the "Ще" sheet's other
/// tiles, which isn't an expense and stays out of this list.
class RecentTransactionsList extends StatelessWidget {
  final int maxItems;
  const RecentTransactionsList({super.key, this.maxItems = 5});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceCubit, MaintenanceState>(
      builder: (context, state) {
        final items = _mergeRecords(state).take(maxItems).toList();
        if (items.isEmpty) return const _EmptyTransactions();

        final settingsCubit = context.watch<SettingsCubit>();
        final currency = settingsCubit.state.currency;
        final currencyService = context.read<CurrencyService>();
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).recent_transactions, style: textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final item in items)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: item == items.last
                        ? BorderSide.none
                        : BorderSide(color: context.brandTheme.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: _categoryColor(item.category), shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label, style: textTheme.bodyMedium),
                          Text(
                            '${_categoryLabel(item.category, context)} · ${item.date.day} ${_kUkMonthsShort[item.date.month - 1]}',
                            style: textTheme.bodySmall?.copyWith(color: AppColors.grey700),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${currencyService.convert(item.amount, currency, fromCurrency: item.currency).toStringAsFixed(0)} $currency',
                      style: textTheme.bodyMedium?.merge(context.brandTheme.moneyTextStyle),
                    ),
                  ],
                ),
              ),
          ],
          ),
        );
      },
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.directions_car_outlined, size: 36, color: AppColors.grey700),
          const SizedBox(height: 12),
          Text(
            S.of(context).no_transactions_title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context).no_transactions_subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
          ),
        ],
      ),
    );
  }
}
