import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/reminders/presentation/widgets/reminder_dialog.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RemindersScreen extends StatefulWidget {
  final String ownerId;

  const RemindersScreen({super.key, required this.ownerId});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, CarState>(
      builder: (context, carState) {
        final carId = carState.carId;

        if (carId.isEmpty) {
          return Center(child: Text(S.of(context).no_car_selected));
        }

        return BlocProvider(
          create: (_) => ReminderCubit(
            repository: context.read<ReminderRepository>(),
            carNumber: carId,
            ownerId: widget.ownerId,
            pushHelper: context.read<PushHelper>(),
          )..load(),
          child: const _RemindersView(),
        );
      },
    );
  }
}

class _RemindersView extends StatelessWidget {
  const _RemindersView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      // Нагадування is a bottom-nav tab (peer of Дім/Штрафи), not a pushed
      // sub-page - no back arrow, matching the redesigned Штрафи tab's
      // chrome. The "+" moved from a FAB into the header, per the mockup.
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        automaticallyImplyLeading: false,
        title: Text(S.of(context).reminder, style: textTheme.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.blue700),
            onPressed: () {
              final cubit = context.read<ReminderCubit>();
              showDialog(
                context: context,
                barrierColor: AppColors.transparent,
                builder: (_) => ReminderDialog(cubit: cubit, onSaved: () => cubit.load()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ReminderCubit, ReminderState>(
          builder: (context, state) {
            final cubit = context.read<ReminderCubit>();

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.reminders.isEmpty) {
              return _EmptyReminders();
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.reminders.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.neutreGrey),
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];

                return ListTile(
                  leading: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) {
                      cubit.updateReminder(
                        reminder.copyWith(isCompleted: value ?? false),
                      );
                    },
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
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
                      builder: (_) => ReminderDialog(
                        cubit: cubit,
                        reminder: reminder,
                        onSaved: () => cubit.load(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacers.verticalXLarge,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(S.of(context).reminder, style: textTheme.title),
          ),
          AppSpacers.verticalGigantic,
          const Center(child: EmptyStateIcon()),
          AppSpacers.verticalLarge,
          Center(
            child: Text(
              S.of(context).no_reminders,
              style: textTheme.noFinesText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared empty-state circle+check icon - also used by the Штрафи tab's
/// empty state (fines_screeen.dart).
class EmptyStateIcon extends StatelessWidget {
  const EmptyStateIcon({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.blueGrey25),
      child: Icon(Icons.check, color: AppColors.neutreBlanc, size: size * 0.8),
    );
  }
}
