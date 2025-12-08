import 'package:core_localization/generated/l10n.dart';

import 'package:fines_plus/features/home/presentation/widgets/action_detail_sheet_interface.dart';
import 'package:flutter/material.dart';

class InsuranceDetailSheet extends StatefulWidget implements ActionDetailSheetInterface {
  final void Function(Map<String, dynamic>)? onSave;
  final String? comment;

  const InsuranceDetailSheet({super.key, this.comment, this.onSave});

  @override
  State<InsuranceDetailSheet> createState() => _InsuranceDetailSheetState();
}

class _InsuranceDetailSheetState extends State<InsuranceDetailSheet> {
  late TextEditingController intervalDaysController;
  late TextEditingController commentController;
  late TextEditingController dateController;

  bool byDate = true;
  String intervalUnit = "days";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    intervalDaysController = TextEditingController();
    commentController = TextEditingController(text: widget.comment ?? "");
    dateController = TextEditingController();
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
  void dispose() {
    intervalDaysController.dispose();
    commentController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(S.of(context).insurance, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
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
                labelText: S.of(context).last_insurance_date,
                border: OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: byDate, onChanged: (v) => setState(() => byDate = v ?? true)),
                Text(S.of(context).by_date),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(labelText: S.of(context).comment, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final intervalTime = _buildIntervalFromUI();
                  final result = {
                    "description": S.of(context).insurance,
                    "date": selectedDate,
                    "intervalDays": intervalTime?.inDays,
                    "comment": commentController.text,
                    "byDate": byDate,
                    "isInsurance": true,
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
