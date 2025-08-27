import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/history_cubit.dart';
import 'package:core_cubit/cubit/history_state.dart';
import 'package:core_repository/history_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class HistoryScreen extends StatelessWidget {
  final String carNumber;
  const HistoryScreen({super.key, required this.carNumber});

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
  const _HistoryView({required this.carNumber});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
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
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                itemCount: state.history.length + 1,
                separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('Історія перевірки', style: textTheme.title),
                    );
                  }

                  final item = state.history[index - 1];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
