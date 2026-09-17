import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DatePickerCard extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerCard({super.key, this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () async {
        DateTime now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) onDateSelected(picked);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutreBlanc,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(S.of(context).date, style: textTheme.subtitleText.copyWith(fontSize: 14)),
            ),
            AppSpacers.verticalXSmall,
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                selectedDate != null
                    ? "${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}"
                    : S.of(context).select_date,
                style: selectedDate != null
                    ? textTheme.historyText.copyWith(fontSize: 16)
                    : textTheme.hintText.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

