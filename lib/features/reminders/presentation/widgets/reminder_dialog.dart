import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_bottom_sheet.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Opens the "Нове нагадування"/"Редагувати нагадування" form in the same
/// [AppBottomSheet] shell as the Паливо/ТО/Мийка/Тюнінг quick-add sheets,
/// instead of a centered AlertDialog - keeps every "add a thing" flow in
/// this app looking the same. Resolves with `true` once actually saved
/// (vs. dismissed via the sheet's close button), so [onSaved] only fires
/// on a real save.
Future<void> showReminderSheet(
  BuildContext context, {
  required ReminderCubit cubit,
  ReminderModel? reminder,
  VoidCallback? onSaved,
}) async {
  final formKey = GlobalKey<_ReminderFormState>();
  final saved = await AppBottomSheet.show<bool>(
    context,
    title: reminder == null ? S.of(context).new_reminder : S.of(context).edit_reminder,
    contentBuilder: (_) => _ReminderForm(key: formKey, cubit: cubit, reminder: reminder),
    saveLabel: S.of(context).save,
    onSave: () => formKey.currentState?.save(),
  );
  if (saved == true) onSaved?.call();
}

class _ReminderForm extends StatefulWidget {
  final ReminderModel? reminder;
  final ReminderCubit cubit;

  const _ReminderForm({super.key, this.reminder, required this.cubit});

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
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

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> save() async {
    final cubit = widget.cubit;
    if (cubit.carNumber.isEmpty) return;

    final newReminder = ReminderModel(
      id: widget.reminder?.id ?? 'reminder_${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text.trim().isEmpty ? 'Test notification' : titleController.text.trim(),
      description: descriptionController.text.trim().isEmpty ? 'Push check' : descriptionController.text.trim(),
      dateTime: selectedDateTime,
      isCompleted: widget.reminder?.isCompleted ?? false,
      isPlannedService: widget.reminder?.isPlannedService ?? false,
      plannedCategory: widget.reminder?.plannedCategory,
      ownerId: cubit.ownerId,
    );

    try {
      if (widget.reminder == null) {
        await cubit.addReminder(newReminder);
      } else {
        await cubit.updateReminder(newReminder);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      debugPrint('Reminder saved and scheduled: ${newReminder.id}');
    } catch (e, stackTrace) {
      debugPrint('Error saving reminder: $e');
      debugPrint('$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).garage_action_error}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldCard(
          label: S.of(context).title,
          child: TextField(
            controller: titleController,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppFieldCard(
          label: S.of(context).description,
          child: TextField(
            controller: descriptionController,
            maxLines: 2,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickDateTime,
          child: Material(
            color: AppColors.neutreBlanc,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.brandTheme.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(S.of(context).select_date, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(selectedDateTime),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.catOther),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
