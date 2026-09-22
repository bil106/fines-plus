import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/domain/planned_service.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/reminders/presentation/reminder_status_tint.dart';
import 'package:fines_plus/features/reminders/presentation/widgets/reminder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

const _maxListHeight = 220.0;
const _dateTintAlpha = 0.45;

/// The user's not-yet-done planned services, shown under the work list in the
/// "ТО" sheet: the date is amber until the day passes, then red. Scrolls when
/// there are many; each one can be edited or deleted.
class PlannedServicesList extends StatelessWidget {
  final ReminderCubit cubit;

  /// The sheet this list belongs to (null for the main "ТО" one).
  final String? category;

  const PlannedServicesList({super.key, required this.cubit, this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderCubit, ReminderState>(
      bloc: cubit,
      buildWhen: (previous, current) => previous.reminders != current.reminders,
      builder: (context, state) {
        final planned =
            state.reminders
                .where(
                  (r) =>
                      r.isPlannedService &&
                      !r.isCompleted &&
                      r.plannedCategory == category,
                )
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        if (planned.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).planned_services,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700,
                ),
              ),
              AppSpacers.verticalSmall,
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _maxListHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: planned.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _PlannedServiceRow(
                    reminder: planned[index],
                    cubit: cubit,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlannedServiceRow extends StatelessWidget {
  final ReminderModel reminder;
  final ReminderCubit cubit;

  const _PlannedServiceRow({required this.reminder, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tint = PlannedService.status([reminder], DateTime.now()).tint;
    final dateColor = tint == null
        ? AppColors.neutreBlanc
        : Color.alphaBlend(
            tint.withValues(alpha: _dateTintAlpha),
            AppColors.neutreBlanc,
          );

    return Row(
      children: [
        Expanded(
          child: Text(
            reminder.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: dateColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('dd.MM.yyyy').format(reminder.dateTime.toLocal()),
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.black87,
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.grey700),
          onSelected: (value) {
            if (value == 'delete') {
              cubit.deleteReminder(reminder.id);
            } else {
              showReminderSheet(context, cubit: cubit, reminder: reminder);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(S.of(context).edit)),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                S.of(context).delete,
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
