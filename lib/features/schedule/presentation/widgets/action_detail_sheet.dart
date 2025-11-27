import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController intervalController;
  late TextEditingController commentController;

  bool byDate = false;
  bool byMileage = true;
  DateTime? selectedDate;
  final List<String> nameOptions = ['Oil', 'Coolant', 'Service', 'Repair', 'Battery', 'Tuning', 'Tires', 'Insurance'];
  @override
  void initState() {
    super.initState();
    final settingsCubit = context.read<SettingsCubit>();
    final unit = settingsCubit.state.unit;

    descriptionController = TextEditingController(text: widget.description);
    categoryController = TextEditingController(text: widget.category);
    dateController = TextEditingController(text: widget.lastServiceDate);
    commentController = TextEditingController(text: widget.comment);

    final mileageValue = widget.lastMileage?.toDouble() ?? 0;
    final intervalValue = widget.intervalKm?.toDouble() ?? 0;

    mileageController = TextEditingController(
        text: unit == 'mil' ? (mileageValue * 0.621371).toStringAsFixed(0) : mileageValue.toStringAsFixed(0));

    intervalController = TextEditingController(
        text: unit == 'mil' ? (intervalValue * 0.621371).toStringAsFixed(0) : intervalValue.toStringAsFixed(0));

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
    final settingsCubit = context.watch<SettingsCubit>();
    final unit = settingsCubit.state.unit;
    // final unitStream = UnitStream(settingsCubit);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 1,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.description ?? S.of(context).new_task, style: textTheme.black18W500)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            AppSpacers.verticalMedium,
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list, color: AppColors.blueAccent),
              ),
              value: nameOptions.contains(categoryController.text) ? categoryController.text : null,
              items: nameOptions.map((name) => DropdownMenuItem<String>(value: name, child: Text(name))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    categoryController.text = value;
                  });
                }
              },
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
                  // --- Input Date ---
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

            // --- Mileage ---
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(labelText: "${S.of(context).mileage} ($unit)", border: OutlineInputBorder()),
            ),
            AppSpacers.verticalMedium,

            // --- Interval ---
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(
                labelText: "${S.of(context).periodicity} ($unit)",
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
                    "description": descriptionController.text,
                    "category": categoryController.text,
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
                      final category = (result["title"] as String).isNotEmpty ? result["title"] : 'Unknown';
                await cubit.onTaskCreated(result, labelKey: category.toString());
                  }

                  Navigator.pop(context, result);
                },
                child: Text(S.of(context).save),
              ),)
          ],
        ),
      ),
    );
  }
}

