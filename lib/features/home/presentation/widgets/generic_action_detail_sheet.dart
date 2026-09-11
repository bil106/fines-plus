import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/home/presentation/widgets/action_detail_sheet_interface.dart';
import 'package:flutter/material.dart';

class GenericActionDetailSheet extends StatefulWidget implements ActionDetailSheetInterface {
  final String? description;

  const GenericActionDetailSheet({super.key, this.description});

  @override
  State<GenericActionDetailSheet> createState() => _GenericActionDetailSheetState();
}

class _GenericActionDetailSheetState extends State<GenericActionDetailSheet> {
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController mileageController;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.description);
    dateController = TextEditingController();
    mileageController = TextEditingController();
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
                Expanded(child: Text(widget.description ?? S.of(context).action, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration:  InputDecoration(labelText: S.of(context).description, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  dateController.text = "${date.day}.${date.month}.${date.year}";
                }
              },
              decoration:  InputDecoration(labelText: S.of(context).date, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(labelText: S.of(context).mileage, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final result = {
                    "description": descriptionController.text,
                    "date": dateController.text,
                    "mileage": mileageController.text,
                  };
                  Navigator.pop(context, result);
                },
                child:  Text(S.of(context).save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
