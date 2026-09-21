// ignore_for_file: unused_element_parameter, avoid_types_as_parameter_names

import 'package:auto_route/auto_route.dart';

import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';

import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class HistoryScreen extends StatelessWidget {
  final String carNumber;
  final VoidCallback? onBack;
  const HistoryScreen({super.key, required this.carNumber, this.onBack});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HistoryCubit(repository: HistoryRepository(FirebaseFirestore.instance), carCubit: context.read<CarCubit>())
            ..loadHistory(carNumber),
      child: _HistoryView(carNumber: carNumber),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final String carNumber;
  final VoidCallback? onBack;
  const _HistoryView({required this.carNumber, this.onBack});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        leading: AppBackButton(
          onPressed: () {
            final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
            homeState?.openPage(HomePage.carInfo);
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HistoryError) {
              return Center(child: Text('${S.of(context).error} ${state.message}'));
            }

            if (state is HistoryEmpty) {
              return Center(child: Text(S.of(context).history_empty));
            }

            if (state is HistoryLoaded) {
              final totalFines = state.history.fold<int>(0, (sum, record) => sum + record.fines.length);
              final paidCount = state.history.fold<int>(0, (sum, record) => sum + record.paidFines.length);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${S.of(context).total_fines} $totalFines',
                          style: textTheme.subtitleText.copyWith(fontWeight: FontWeight.bold, color: AppColors.red),
                        ),
                        if (paidCount > 0) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '✓ $paidCount',
                              style: textTheme.subtitleText.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      itemCount: state.history.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.neutreGrey),
                      itemBuilder: (context, index) {
                        final item = state.history[index];
                        return _HistoryRecord(item: item);
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HistoryRecord extends StatelessWidget {
  final FineHistory item;
  const _HistoryRecord({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<HistoryCubit>();

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${S.of(context).auto}: ${item.carNumber}", style: textTheme.carNumber),
          Text(
            "${S.of(context).technical_data} ${item.docSeries} ${item.docNumber}",
            style: textTheme.historyText,
          ),
          Row(
            children: [
              Text(
                "${S.of(context).fines_length} ${item.fines.length}",
                style: textTheme.historyText.copyWith(
                  color: item.fines.isEmpty ? Colors.green : AppColors.red,
                ),
              ),
              if (item.paidFines.isNotEmpty && item.fines.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  "(${S.of(context).paid}: ${item.paidFines.length}/${item.fines.length})",
                  style: textTheme.historyText.copyWith(color: Colors.green.shade600),
                ),
              ],
            ],
          ),
          Text(
            "${S.of(context).verif_date} ${DateFormat('dd.MM.yyyy HH:mm').format(item.checkedAt)}",
            style: textTheme.historyText,
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: AppColors.red),
        onPressed: () => cubit.deleteSingle(item.id),
      ),
      children: item.fines.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  S.of(context).no_fines,
                  style: textTheme.historyText.copyWith(color: Colors.green),
                ),
              ),
            ]
          : item.fines.asMap().entries.map((entry) {
              final fineIndex = entry.key;
              final fine = entry.value;
              final fineId = fine['id']?.toString() ?? '$fineIndex';
              final isPaid = item.paidFines.contains(fineId);

              final amount = fine['amount'] ?? fine['suma'] ?? fine['penalty'] ?? '';
              final description = fine['description'] ?? fine['article'] ?? fine['offense'] ?? '';
              final date = fine['date'] ?? fine['violationDate'] ?? fine['datetime'] ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPaid ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (description.toString().isNotEmpty)
                            Text(description.toString(), style: textTheme.historyText),
                          if (amount.toString().isNotEmpty)
                            Text(
                              '${S.of(context).amount}: $amount грн',
                              style: textTheme.historyText.copyWith(fontWeight: FontWeight.bold),
                            ),
                          if (date.toString().isNotEmpty)
                            Text('${S.of(context).verif_date} $date', style: textTheme.historyText),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Checkbox(
                          value: isPaid,
                          activeColor: Colors.green,
                          onChanged: (val) => cubit.markFineAsPaid(item.id, fineId, val ?? false),
                        ),
                        Text(
                          S.of(context).paid,
                          style: textTheme.historyText.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }
}
