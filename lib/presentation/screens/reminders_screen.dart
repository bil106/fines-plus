// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:auto_route/auto_route.dart';
import 'package:core/features/reminders/widgets/reminder_dialog.dart';
import 'package:core_cubit/cubit/reminder_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';

import 'package:design_system/constants/app_spacers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: BlocBuilder<ReminderCubit, ReminderState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.reminders.isEmpty) {
                return _EmptyReminders();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                itemBuilder: (context, index) {
                  final reminder = state.reminders[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0) ...[
                          Text(
                            S.of(context).reminder,
                            style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 36),
                          ),
                          AppSpacers.verticalXLarge,
                        ],
                        ListTile(
                          leading: Checkbox(
                            value: reminder.isCompleted,
                            onChanged: (value) {
                              context.read<ReminderCubit>().updateReminder(
                                reminder.copyWith(isCompleted: value ?? false),
                              );
                            },
                          ),
                          title: Text(
                            reminder.title,
                            style: TextStyle(
                              decoration: reminder.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              fontWeight: FontWeight.w500,
                              fontSize: 24
                            ),
                          ),
                          subtitle: Text(
                            '${reminder.description}\n${DateFormat('dd.MM.yyyy HH:mm').format(reminder.dateTime)}',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24)
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<ReminderCubit>().deleteReminder(reminder.id);
                            },
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (_) => ReminderDialog(reminder: reminder),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(),
                itemCount: state.reminders.length,
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, barrierColor: Colors.transparent, builder: (_) => const ReminderDialog());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacers.verticalXLarge,
          const Text('Нагадування', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 150),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
              child: const Icon(Icons.check, color: Colors.white, size: 120),
            ),
          ),
          AppSpacers.verticalLarge,
          const Center(
            child: Text('Нагадування поки що немає', style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
