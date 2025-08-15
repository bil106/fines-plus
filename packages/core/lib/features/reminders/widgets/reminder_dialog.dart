import 'package:core_cubit/cubit/reminder_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
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

    return AlertDialog(
      backgroundColor: AppColors.neutreBlanc,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06, 
        vertical: 24,
      ),
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        widget.reminder == null ? 'Нове нагадування' : 'Редагувати нагадування',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500, 
          minWidth: screenWidth * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacers.verticalMedium,
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Заголовок', labelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
              ),
              AppSpacers.verticalLarge,
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Опис',labelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
              ),
              AppSpacers.verticalLarge,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(selectedDateTime),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
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
                          setState(() {
                            selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: const Text('Вибрати дату',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
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
          child: const Text('Скасування',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        ),
    ElevatedButton(
          onPressed: () {
            final newReminder = ReminderModel(
              id: widget.reminder?.id ?? '',
              title: titleController.text,
              description: descriptionController.text,
              dateTime: selectedDateTime,
              isCompleted: widget.reminder?.isCompleted ?? false,
            );

            final cubit = widget.cubit; 
            if (widget.reminder == null) {
              cubit.addReminder(newReminder);
            } else {
              cubit.updateReminder(newReminder);
            }

            widget.onSaved?.call();
            Navigator.pop(context);
          },
          child: const Text('Зберегти', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        )

      ],
    );
  }
}

