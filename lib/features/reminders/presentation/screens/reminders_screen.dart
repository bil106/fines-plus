import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:fines_plus/features/reminders/presentation/widgets/reminder_dialog.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RemindersScreen extends StatefulWidget {
  final String ownerId;
  final VoidCallback? onBack;

  const RemindersScreen({super.key, required this.ownerId, this.onBack});

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

        return _RemindersView(onBack: widget.onBack);
      },
    );
  }
}

class _RemindersView extends StatelessWidget {
  final VoidCallback? onBack;

  const _RemindersView({this.onBack});

  void _openNewReminderDialog(BuildContext context) {
    final cubit = context.read<ReminderCubit>();
    showReminderSheet(context, cubit: cubit, onSaved: () => cubit.load());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppBar(
        backgroundColor: context.brandTheme.surfaceBg,
        automaticallyImplyLeading: false,
        leading: onBack == null
            ? null
            : Padding(padding: const EdgeInsets.only(left: 20), child: AppBackButton(onPressed: onBack)),
        leadingWidth: onBack == null ? null : 68,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: onBack == null ? 20 : 12,
        actionsPadding: const EdgeInsets.only(right: 20),
        title: Text(S.of(context).notifications,
          maxLines: 2,
          style: textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
        actions: [
          IconButton(
            tooltip: S.of(context).new_reminder,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: AppColors.neutreBlanc,
              minimumSize: const Size(34, 34), padding: EdgeInsets.zero, shape: const CircleBorder()),
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => _openNewReminderDialog(context),
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

            if (state.items.isEmpty) {
              return _EmptyReminders(onAdd: () => _openNewReminderDialog(context));
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: state.items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = state.items[index];
                final reminder = item.manual;
                if (reminder == null) return ReminderCard(item: item);

                return ReminderCard(
                  item: item,
                  onToggle: () => cubit.updateReminder(
                    reminder.copyWith(isCompleted: !reminder.isCompleted)),
                  onDelete: () => cubit.deleteReminder(reminder.id),
                  onTap: () {
                    showReminderSheet(
                      context,
                      cubit: cubit,
                      reminder: reminder,
                      onSaved: () => cubit.load(),
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
  final VoidCallback onAdd;

  const _EmptyReminders({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 40, color: AppColors.catOther),
            const SizedBox(height: 10),
            Text(S.of(context).no_reminders,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink),
              textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(S.of(context).no_reminders_body,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.neutreBlanc,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: Text(S.of(context).add_reminder_button),
            ),
          ],
        ),
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
