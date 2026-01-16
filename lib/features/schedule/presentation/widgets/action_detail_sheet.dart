import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/mileageInput_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/additional_options_widget.dart';
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
  late TextEditingController intervalKmController;
  late TextEditingController intervalDaysController;
  late TextEditingController commentController;

  bool byDate = false;
  bool byMileage = true;
  bool _showAdditionalOptions = false;
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
      padding: EdgeInsets.only(top: 12, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
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
            AppSpacers.verticalSmall,

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

            AppSpacers.verticalSmall,

            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, MileageInputFormatter(max: 10000000)],
              decoration: InputDecoration(labelText: S.of(context).mileage, border: OutlineInputBorder()),
            ),

            AppSpacers.verticalSmall,
            TextField(
              controller: intervalKmController,
              keyboardType: TextInputType.number,
               inputFormatters: [FilteringTextInputFormatter.digitsOnly, MileageInputFormatter(max: 10000000)],
              decoration: InputDecoration(labelText: S.of(context).interval, border: OutlineInputBorder()),
            ),

            AppSpacers.verticalSmall,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: intervalDaysController,
                    keyboardType: TextInputType.number,
                     inputFormatters: [FilteringTextInputFormatter.digitsOnly, MileageInputFormatter(max: 365)],
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

            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: byDate, onChanged: (v) => setState(() => byDate = v ?? false)),
                    Text(S.of(context).by_date, maxLines: 2, softWrap: true),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: byMileage, onChanged: (v) => setState(() => byMileage = v ?? true)),
                    Text(S.of(context).by_mileage, maxLines: 2, softWrap: true),
                  ],
                ),
              ],
            ),

            TextField(
              controller: commentController,
              maxLines: 2,
              decoration: InputDecoration(labelText: S.of(context).comment, border: OutlineInputBorder()),
            ),          

            TextButton(
              onPressed: () {
                setState(() => _showAdditionalOptions = !_showAdditionalOptions);
              },
              child: Text(
                S.of(context).additional_options,
                style: textTheme.blue20W400.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showAdditionalOptions
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AdditionalOptionsWidget(cubit: context.read<AdditionalOptionsCubit>()),
                    )
                  : const SizedBox.shrink(),
            ),

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
            ),
          ],
        ),
      ),
    );
  }
}
