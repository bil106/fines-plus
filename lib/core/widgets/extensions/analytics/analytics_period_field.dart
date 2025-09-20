import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsPeriodField extends StatefulWidget {
  final DateTime? initialDate;
  final void Function(DateTime)? onChanged;

  const AnalyticsPeriodField({this.initialDate, this.onChanged, super.key});

  @override
  State<AnalyticsPeriodField> createState() => _AnalyticsPeriodFieldState();
}

class _AnalyticsPeriodFieldState extends State<AnalyticsPeriodField> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate != null
            ? toBeginningOfSentenceCase(DateFormat("MMM yyyy", "uk_UK").format(selectedDate!))
            : "",
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.neutreBlanc,
        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.energyBlue),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: AppColors.neutreGrey),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              setState(() {
                selectedDate = DateTime(picked.year, picked.month);
              });
              if (widget.onChanged != null) widget.onChanged!(selectedDate!);
            }
          },
        ),
        border: OutlineInputBorder(borderRadius: AppBorders.radiusLarge, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: AppBorders.radiusLarge, borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      style: textTheme.historyText,
    );
  }
}
