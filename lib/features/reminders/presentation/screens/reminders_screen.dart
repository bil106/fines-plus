import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
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
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppBar(
        backgroundColor: context.brandTheme.surfaceBg,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 88,
        titleSpacing: 20,
        actionsPadding: const EdgeInsets.only(right: 20),
        title: Text(S.of(context).reminder,
          maxLines: 2,
          style: textTheme.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF191A1C))),
        actions: [
          IconButton(
            tooltip: S.of(context).new_reminder,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF207BD7), foregroundColor: Colors.white,
              minimumSize: const Size(44, 44), shape: const CircleBorder()),
            icon: const Icon(Icons.add, size: 24),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: state.reminders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];

                return _ReminderCard(
                  reminder: reminder,
                  onToggle: () => cubit.updateReminder(
                    reminder.copyWith(isCompleted: !reminder.isCompleted)),
                  onDelete: () => cubit.deleteReminder(reminder.id),
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

class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  const _ReminderCard({required this.reminder, required this.onToggle, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final due = reminder.dateTime.toLocal();
    final days = DateTime.utc(due.year, due.month, due.day)
        .difference(DateTime.utc(now.year, now.month, now.day)).inDays;
    final overdue = due.isBefore(now) && !reminder.isCompleted;
    final soon = !reminder.isCompleted && !overdue && days <= 14;
    final accent = reminder.isCompleted ? const Color(0xFF79B58A)
        : overdue ? const Color(0xFFBE3540)
        : soon ? const Color(0xFF00A99A) : const Color(0xFF6366F1);
    final status = reminder.isCompleted ? S.of(context).done
        : overdue ? S.of(context).reminder_overdue
        : soon ? S.of(context).reminder_soon : '$days ${S.of(context).days}';
    final statusWidget = Text(status, style: theme.bodySmall?.copyWith(
      fontSize: 14, fontWeight: FontWeight.w700,
      color: overdue ? const Color(0xFFBE3540) : soon ? const Color(0xFFBA8700) : const Color(0xFF707070)));
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.brandTheme.surfaceBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(builder: (context, constraints) {
            final stacked = constraints.maxWidth < 300 || MediaQuery.textScalerOf(context).scale(16) > 20;
            return Row(
              children: [
                Semantics(
                  checked: reminder.isCompleted,
                  label: reminder.title,
                  child: SizedBox.square(
                    dimension: 48,
                    child: IconButton(
                      onPressed: onToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: accent.withValues(alpha: 0.16), foregroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                      icon: Icon(reminder.isCompleted ? Icons.check : Icons.circle,
                        size: reminder.isCompleted ? 22 : 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.title, style: theme.bodyLarge?.copyWith(
                      fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF202124),
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : TextDecoration.none)),
                    if (reminder.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(reminder.description, style: theme.bodySmall?.copyWith(fontSize: 14, color: const Color(0xFF707070))),
                    ],
                    const SizedBox(height: 4),
                    Text(DateFormat('d MMM yyyy · HH:mm', Localizations.localeOf(context).toString()).format(due),
                      style: theme.bodySmall?.copyWith(fontSize: 14, color: const Color(0xFF707070))),
                    if (stacked) ...[const SizedBox(height: 8), statusWidget],
                  ],
                )),
                if (!stacked) ...[const SizedBox(width: 12), statusWidget],
                PopupMenuButton<String>(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  icon: const Icon(Icons.more_vert, color: Color(0xFF707070), size: 20),
                  onSelected: (action) => action == 'edit' ? onTap() : onDelete(),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(S.of(context).edit)),
                    PopupMenuItem(value: 'delete', child: Text(S.of(context).delete, style: const TextStyle(color: AppColors.red))),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders();

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(S.of(context).no_reminders,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF707070)),
            textAlign: TextAlign.center),
        ],
      ),
    ),
  );
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
