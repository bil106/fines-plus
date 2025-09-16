import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/widgets/extensions/service_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionDetailSheet extends StatefulWidget {
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
    this.byDate = true,
    this.byMileage = false,
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

  bool byDate = true;
  bool byMileage = false;
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
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title ?? S.of(context).new_task,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),

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
                    prefixIcon: Icon(Icons.build, color: Colors.blueAccent),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(
                labelText: "${S.of(context).mileage} (${S.of(context).km})",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(
                labelText: "${S.of(context).periodicity} (${S.of(context).km})",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(value: byDate, onChanged: (v) => setState(() => byDate = v ?? true)),
                Text(S.of(context).by_date),
                const SizedBox(width: 16),
                Checkbox(value: byMileage, onChanged: (v) => setState(() => byMileage = v ?? false)),
                Text(S.of(context).by_mileage),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(labelText: S.of(context).comment, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "title": titleController.text,
                    "date": selectedDate,
                    "mileage": int.tryParse(mileageController.text),
                    "intervalKm": int.tryParse(intervalController.text),
                    "intervalDays": int.tryParse(intervalController.text) ?? 180,
                    "byDate": byDate,
                    "byMileage": byMileage,
                    "comment": commentController.text,
                  });
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
