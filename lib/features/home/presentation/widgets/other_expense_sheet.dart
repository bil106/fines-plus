import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/features/expenses/data/models/other_expense_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Інше" tile content in the dashboard's "Ще" (Додати витрату) sheet - a
/// minimal one-off expense that doesn't fit fuel/service/tuning/car wash.
/// Styled to match the Паливо/ТО/Страхування sheets.
class OtherExpenseSheet extends StatefulWidget {
  const OtherExpenseSheet({super.key});

  @override
  State<OtherExpenseSheet> createState() => OtherExpenseSheetState();
}

class OtherExpenseSheetState extends State<OtherExpenseSheet> {
  final TextEditingController costController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final FocusNode costFocusNode = FocusNode();
  final FocusNode commentFocusNode = FocusNode();

  DateTime? selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final lastMileage = context.read<MaintenanceCubit>().getLastKnownMileage();
    if (lastMileage != null) {
      mileageController.text = lastMileage.toString();
    }
  }

  @override
  void dispose() {
    costController.dispose();
    mileageController.dispose();
    commentController.dispose();
    costFocusNode.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  void save() {
    if (selectedDate == null || costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).fill_date)));
      return;
    }

    final record = OtherExpenseRecord(
      date: selectedDate!,
      cost: double.tryParse(costController.text) ?? 0,
      mileage: int.tryParse(mileageController.text) ?? 0,
      currency: context.read<SettingsCubit>().state.currency,
      comment: commentController.text.trim().isEmpty ? null : commentController.text.trim(),
    );

    context.read<MaintenanceCubit>().addOtherRecord(record);
    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settings = context.watch<SettingsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatePickerCard(selectedDate: selectedDate, onDateSelected: (date) => setState(() => selectedDate = date)),
        const SizedBox(height: 16),
        AppFieldCard(
          label: S.of(context).mileage,
          child: TextField(
            controller: mileageController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => costFocusNode.requestFocus(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
          ),
        ),
        const SizedBox(height: 16),
        AppFieldCard(
          label: S.of(context).cost,
          child: TextField(
            controller: costController,
            focusNode: costFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => commentFocusNode.requestFocus(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
              suffixText: ' ${settings.state.currency}',
              suffixStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
          ),
        ),
        const SizedBox(height: 16),
        AppFieldCard(
          label: S.of(context).comment,
          child: TextField(
            controller: commentController,
            focusNode: commentFocusNode,
            maxLines: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
          ),
        ),
      ],
    );
  }
}
