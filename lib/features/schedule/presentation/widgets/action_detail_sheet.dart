import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionDetailSheet extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onSave;
  final String? title;
  final String? lastServiceDate;
  final int? lastMileage;
  final int? actualMileage;
  final int? intervalKm;
  final String? comment;
  final bool byDate;
  final bool byMileage;

  const ActionDetailSheet({
    super.key,
    this.title,
    this.lastServiceDate,
    this.lastMileage,
    this.actualMileage,
    this.intervalKm,
    this.comment,
    this.byDate = false,
    this.byMileage = true,
    this.onSave,
  });

  @override
  State<ActionDetailSheet> createState() => _ActionDetailSheetState();
}

class _ActionDetailSheetState extends State<ActionDetailSheet> {
  late TextEditingController titleController;
  late TextEditingController dateController;
  late TextEditingController mileageController;
  late TextEditingController intervalController;
  late TextEditingController commentController;

  bool byDate = false;
  bool byMileage = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.title);
    dateController = TextEditingController(text: widget.lastServiceDate);
    mileageController = TextEditingController(text: widget.lastMileage?.toString());
    intervalController = TextEditingController(text: widget.intervalKm?.toString());
    commentController = TextEditingController(text: widget.comment);

    byDate = widget.byDate;
    byMileage = widget.byMileage;

    if (widget.lastServiceDate != null) {
      final parts = widget.lastServiceDate!.split('.');
      if (parts.length == 3) {
        selectedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 1, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.title ?? S.of(context).new_task, style: textTheme.black18W500)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            AppSpacers.verticalMedium,

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) return ServiceList.names;
                return ServiceList.names.where((option) => option.toLowerCase().contains(value.text.toLowerCase()));
              },
              onSelected: (val) {
                titleController.text = val;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                titleController = titleController;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: S.of(context).name,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.build, color: AppColors.blueAccent),
                  ),
                );
              },
            ),
            AppSpacers.verticalMedium,
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: S.of(context).date_previous_maintenance,
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacers.verticalMedium,
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(
                labelText: "${S.of(context).mileage} (${S.of(context).km})",
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacers.verticalMedium,
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(
                labelText: "${S.of(context).periodicity} (${S.of(context).km})",
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacers.verticalMedium,
            Row(
              children: [
                Checkbox(value: byDate, onChanged: (v) => setState(() => byDate = v ?? false)),
                Text(S.of(context).by_date),
                AppSpacers.horizontalMediumLarge,
                Checkbox(value: byMileage, onChanged: (v) => setState(() => byMileage = v ?? true)),
                Text(S.of(context).by_mileage),
              ],
            ),
            AppSpacers.verticalMedium,
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(labelText: S.of(context).comment, border: OutlineInputBorder()),
            ),
            AppSpacers.verticalMediumLarge,

         SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = {
                    "title": titleController.text,
                    "date": selectedDate,
                    "mileage": int.tryParse(mileageController.text),
                    "intervalKm": int.tryParse(intervalController.text),
                    "intervalDays": int.tryParse(intervalController.text) ?? 180,
                    "byDate": byDate,
                    "byMileage": byMileage,
                    "comment": commentController.text,
                  };

                  if (widget.onSave != null) {
                    widget.onSave!(result); 
                      final cubit = context.read<QuickActionsCubit>();
                await cubit.onOilTaskCreated();
                  }

                  Navigator.pop(context, result);
                },
                child: Text(S.of(context).save),
              ),
            )

          ],
        ),
      ),
    );
  }
}
