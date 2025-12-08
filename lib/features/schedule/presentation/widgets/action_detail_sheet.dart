import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionDetailSheet extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onSave;
  final String? description;
  final String? category;
  final String? lastServiceDate;
  final int? lastMileage;
  final int? actualMileage;
  final int? intervalKm;
  final String? comment;
  final bool byDate;
  final bool byMileage;

  const ActionDetailSheet({
    super.key,
    this.description,
    this.category,
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
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController dateController;
  late TextEditingController mileageController;
  late TextEditingController intervalKmController;

  late TextEditingController intervalDaysController;

  late TextEditingController commentController;

  bool byDate = false;
  bool byMileage = true;
  String intervalUnit = "days";
  DateTime? selectedDate;
  String? selectedCategory;

  final Map<String, String> items = {
    "oil": S.current.oil_icon,
    "coolant": S.current.coolant_icon,
    "service": S.current.service,
    "repair": S.current.repair_icon,
    "battery": S.current.battery,
    "tuning": S.current.tuning,
    "tires": S.current.tires_icon,
    "insurance": S.current.insurance,
  };

  @override
  void initState() {
    super.initState();

    descriptionController = TextEditingController(text: widget.description);
    categoryController = TextEditingController(text: widget.category);
    dateController = TextEditingController(text: widget.lastServiceDate);
    mileageController = TextEditingController(text: widget.lastMileage?.toString());
    intervalKmController = TextEditingController(text: widget.intervalKm?.toString());
    intervalDaysController = TextEditingController();
    commentController = TextEditingController(text: widget.comment);

    byDate = widget.byDate;
    byMileage = widget.byMileage;

    selectedCategory = widget.category;

    if (widget.lastServiceDate != null) {
      final parts = widget.lastServiceDate!.split('.');
      selectedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
  }

  Duration? _buildIntervalFromUI() {
    final value = int.tryParse(intervalDaysController.text);
    if (value == null || value <= 0) return null;

    switch (intervalUnit) {
      case "days":
        return Duration(days: value);
      case "months":
        return Duration(days: value * 30);
      case "years":
        return Duration(days: value * 365);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.description ?? S.of(context).next, style: textTheme.titleMedium)),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),

            SizedBox(height: 16),

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) return ServiceList.names;
                return ServiceList.names.where((option) => option.toLowerCase().contains(value.text.toLowerCase()));
              },
              onSelected: (val) {
                descriptionController.text = val;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                descriptionController = descriptionController;
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
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  selectedDate = date;
                  dateController.text =
                      "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
                }
              },
              decoration: InputDecoration(
                labelText: S.of(context).last_service_date,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),

            AppSpacers.verticalMedium,

            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: S.of(context).mileage, border: OutlineInputBorder()),
            ),
            AppSpacers.verticalMedium,
            TextField(
              controller: intervalKmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: S.of(context).interval, border: OutlineInputBorder()),
            ),

            AppSpacers.verticalMedium,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: intervalDaysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: S.of(context).interval_by_date,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                DropdownButton<String>(
                  value: intervalUnit,
                  items: [
                    DropdownMenuItem(value: "days", child: Text(S.of(context).days_interv)),
                    DropdownMenuItem(value: "months", child: Text(S.of(context).month)),
                    DropdownMenuItem(value: "years", child: Text(S.of(context).years)),
                  ],
                  onChanged: (v) => setState(() => intervalUnit = v!),
                ),
              ],
            ),

            AppSpacers.verticalMedium,
            Row(
              children: [
                Checkbox(value: byDate, onChanged: (v) => setState(() => byDate = v ?? false)),
                Text(S.of(context).by_date),
                SizedBox(width: 24),
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

            AppSpacers.verticalLargeXL,

         SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final intervalTime = _buildIntervalFromUI();

                  final result = {
                    "description": descriptionController.text,
                    "category": categoryController.text,
                    "date": selectedDate,
                    "mileage": int.tryParse(mileageController.text) ?? 0,
                    "intervalKm": int.tryParse(intervalKmController.text),
                    "intervalDays": intervalTime?.inDays,
                    "comment": commentController.text,
                    "byDate": byDate,
                    "byMileage": byMileage,
                  };

                  if (widget.onSave != null) widget.onSave!(result);

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
