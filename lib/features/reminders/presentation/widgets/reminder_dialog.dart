

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class ReminderDialog extends StatefulWidget {
  final ReminderModel? reminder;
  final VoidCallback? onSaved;
  final ReminderCubit cubit;

  const ReminderDialog({super.key, this.reminder, this.onSaved, required this.cubit});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.reminder?.title ?? '');
    descriptionController = TextEditingController(text: widget.reminder?.description ?? '');
    selectedDateTime = widget.reminder?.dateTime ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.energyBlue50,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 24),
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        widget.reminder == null ? S.of(context).new_reminder : S.of(context).edit_reminder,
        style: textTheme.black30bold,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, minWidth: screenWidth * 0.8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacers.verticalMedium,
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: S.of(context).title, labelStyle: textTheme.black18W400),
              ),
              AppSpacers.verticalLarge,
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: S.of(context).description, labelStyle: textTheme.black18W400),
              ),
              AppSpacers.verticalLarge,
              Row(
                children: [
                  Expanded(
                    child: Text(DateFormat('dd.MM.yyyy HH:mm').format(selectedDateTime), style: textTheme.black18W500),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );
                        if (time != null) {
                          if (!mounted) return;
                          setState(() {
                            selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                    child: Text(S.of(context).select_date, style: textTheme.black18W500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel, style: textTheme.black18W500),
        ),
        ElevatedButton(
          onPressed: () async {
            final cubit = widget.cubit;
            if (cubit.carNumber.isEmpty) return;

            final newReminder = ReminderModel(
              id: widget.reminder?.id ?? 'reminder_${DateTime.now().millisecondsSinceEpoch}',
              title: titleController.text.trim().isEmpty ? 'Test notification' : titleController.text.trim(),
              description: descriptionController.text.trim().isEmpty ? 'Push check' : descriptionController.text.trim(),
              dateTime: selectedDateTime,
              isCompleted: widget.reminder?.isCompleted ?? false,
              userId: cubit.userId, 
            );

            try {
              if (widget.reminder == null) {
                await cubit.addReminder(newReminder);
              } else {
                await cubit.updateReminder(newReminder);
              }

              if (!mounted) return;
              Navigator.pop(context);

              
              widget.onSaved?.call();

              debugPrint('Reminder saved and scheduled: ${newReminder.id}');
            } catch (e, stackTrace) {
              debugPrint('Error saving reminder: $e');
              debugPrint('$stackTrace');
            }
          },
          child: Text(S.of(context).save),
        ),
      ],
    );
  }
}
