// ignore_for_file: unused_element_parameter, avoid_types_as_parameter_names

import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/history_cubit.dart';
import 'package:core_cubit/cubit/history_state.dart';
import 'package:core_repository/history_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
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
      create: (_) => HistoryCubit(repository: HistoryRepository(FirebaseFirestore.instance))..loadHistory(carNumber),
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
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(
          color: Colors.black,
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
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is HistoryEmpty) {
              return const Center(child: Text('History is empty'));
            }

     if (state is HistoryLoaded) {
         
              final totalFines = state.history.fold<int>(0, (sum, record) => sum + record.fines.length);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Загальна кількість штрафів: $totalFines',
                      style: textTheme.subtitleText.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: state.history.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final item = state.history[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Авто: ${item.carNumber}", style: textTheme.carNumber),
                              Text("Техпаспорт: ${item.docSeries} ${item.docNumber}", style: textTheme.historyText),
                              Text("Штрафов: ${item.fines.length}", style: textTheme.historyText),
                              Text(
                                "Дата проверки: ${DateFormat('dd.MM.yyyy HH:mm').format(item.checkedAt)}",
                                style: textTheme.historyText,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final cubit = context.read<HistoryCubit>();
                              await cubit.deleteSingle(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed')));
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
