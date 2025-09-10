import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';

class AddMileageDialog extends StatefulWidget {
  final MileageRecord? initialRecord;

  const AddMileageDialog({super.key, this.initialRecord});

  @override
  State<AddMileageDialog> createState() => _AddMileageDialogState();
}

class _AddMileageDialogState extends State<AddMileageDialog> {
  late TextEditingController _startController;
  late TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: widget.initialRecord?.startOdometer.toString() ?? '0');
    _endController = TextEditingController(text: widget.initialRecord?.endOdometer.toString() ?? '0');
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).add_mileage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _startController,
            decoration: InputDecoration(labelText: S.of(context).odometer_beginning),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _endController,
            decoration: InputDecoration(labelText: S.of(context).odometer_today),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
        ElevatedButton(
          onPressed: () {
            final start = int.tryParse(_startController.text) ?? 0;
            final end = int.tryParse(_endController.text) ?? 0;
            if (end > start) {
              Navigator.pop(
                context,
                MileageRecord(
                  month: DateTime(DateTime.now().year, DateTime.now().month),
                  startOdometer: start,
                  endOdometer: end,
                ),
              );
            }
          },
          child: Text(S.of(context).save),
        ),
      ],
    );
  }
}
