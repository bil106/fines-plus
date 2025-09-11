import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionDetailSheet extends StatefulWidget {
  final String title;
  final String priorExecution;
  final String periodicity;

  const ActionDetailSheet({super.key, required this.title, required this.priorExecution, required this.periodicity});

  @override
  State<ActionDetailSheet> createState() => _ActionDetailSheetState();
}

class _ActionDetailSheetState extends State<ActionDetailSheet> {
  bool byDate = true;
  bool byMileage = false;

  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateController.text = widget.priorExecution; 
    mileageController.text = widget.periodicity; 
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Expanded(
                child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),

        
          Text(S.of(context).date_previous_maintenance),
          TextField(
            controller: dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          Text(S.of(context).mileage_time_service),
          TextField(
            controller: mileageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            decoration: InputDecoration(
              hintText: S.of(context).enter_mileage,
              suffixText: S.of(context).km,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

          Text(S.of(context).comment),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: S.of(context).enter_comment,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "date": dateController.text,
                  "mileage": mileageController.text,
                  "comment": commentController.text,
                  "byDate": byDate,
                  "byMileage": byMileage,
                });
              },
              child: Text(S.of(context).save),
            ),
          ),
        ],
      ),
    );
  }
}
