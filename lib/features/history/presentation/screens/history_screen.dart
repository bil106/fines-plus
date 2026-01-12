// ignore_for_file: unused_element_parameter, avoid_types_as_parameter_names

import 'package:auto_route/auto_route.dart';

import 'package:core_localization/generated/l10n.dart';

import 'package:design_system/colors/app_colors.dart';
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
        leading: BackButton(
          color: AppColors.black,
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

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Text(
                      '${S.of(context).total_fines} $totalFines',
                      style: textTheme.subtitleText.copyWith(fontWeight: FontWeight.bold, color: AppColors.red),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      itemCount: state.history.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.neutreGrey),
                      itemBuilder: (context, index) {
                        final item = state.history[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${S.of(context).auto}: ${item.carNumber}", style: textTheme.carNumber),
                              Text(
                                "${S.of(context).technical_data} ${item.docSeries} ${item.docNumber}",
                                style: textTheme.historyText,
                              ),
                              Text("${S.of(context).fines_length} ${item.fines.length}", style: textTheme.historyText),
                              Text(
                                "${S.of(context).verif_date} ${DateFormat('dd.MM.yyyy HH:mm').format(item.checkedAt)}",
                                style: textTheme.historyText,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.red),
                            onPressed: () async {
                              final cubit = context.read<HistoryCubit>();
                              await cubit.deleteSingle(item.id);
                            },
                          ),
                        );
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
