import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/reminders/presentation/widgets/reminder_dialog.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RemindersScreen extends StatelessWidget {
  final String carNumber;
  final String userId; 
  final VoidCallback? onBack;

  const RemindersScreen({
    super.key,
    required this.carNumber,
    required this.userId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReminderCubit(
        repository: context.read<ReminderRepository>(),
        carNumber: carNumber,
        userId: userId, 
        pushHelper: context.read<PushHelper>(),
      )..load(),
      child: _RemindersView(onBack),
    );
  }
}

class _RemindersView extends StatelessWidget {
  final VoidCallback? onBack;
  const _RemindersView(this.onBack);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<ReminderCubit>();

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: onBack ?? () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: BlocBuilder<ReminderCubit, ReminderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.reminders.isEmpty) {
              return const _EmptyReminders();
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              itemCount: state.reminders.length + 1,
              separatorBuilder: (_, __) => const Divider(color: AppColors.neutreGrey),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(S.of(context).reminder, style: textTheme.title),
                  );
                }

                final reminder = state.reminders[index - 1];

                return ListTile(
                  leading: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) {
                      cubit.updateReminder(reminder.copyWith(isCompleted: value ?? false));
                    },
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                  subtitle: Text(
                    '${reminder.description}\n${DateFormat('dd.MM.yyyy HH:mm').format(reminder.dateTime)}',
                    style: textTheme.headlineSmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.red),
                    onPressed: () => cubit.deleteReminder(reminder.id),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: AppColors.transparent,
                      builder: (_) => ReminderDialog(cubit: cubit, reminder: reminder, onSaved: () => cubit.load()),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: AppColors.transparent,
            builder: (_) => ReminderDialog(cubit: cubit, onSaved: () => cubit.load()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacers.verticalXLarge,
          Text(S.of(context).reminder, style: textTheme.title),
          AppSpacers.verticalGigantic,
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.energyBlue),
              child: const Icon(Icons.check, color: AppColors.neutreBlanc, size: 120),
            ),
          ),
          AppSpacers.verticalLarge,
          Center(
            child: Text(S.of(context).no_reminders, style: textTheme.noFinesText, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
