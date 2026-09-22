import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/thousands_separator_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/features/expenses/data/models/other_expense_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
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
    final lastMileageKm = context.read<MaintenanceCubit>().getLastKnownMileage();
    if (lastMileageKm != null) {
      final settingsCubit = context.read<SettingsCubit>();
      final displayValue = UnitStream(settingsCubit).convert(lastMileageKm.toDouble()).round();
      mileageController.text = formatThousands(displayValue);
    }
  }

  /// Inverse of [UnitStream.convert]: the field shows the active unit, but
  /// the stored record always keeps km.
  int _mileageToKm(int displayValue) {
    final unit = context.read<SettingsCubit>().state.unit;
    return unit == 'mil' ? (displayValue / 0.621371).round() : displayValue;
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
      mileage: _mileageToKm(int.tryParse(stripThousandsSeparator(mileageController.text)) ?? 0),
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
        Row(
          children: [
            Expanded(
              child: DatePickerCard(selectedDate: selectedDate, onDateSelected: (date) => setState(() => selectedDate = date)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MileageCard(
                textTheme: textTheme,
                controller: mileageController,
                onSubmitted: (_) => costFocusNode.requestFocus(),
                unitLabel: settings.state.unit == 'mil' ? 'mil' : S.of(context).km,
              ),
            ),
          ],
        ),
        AppSpacers.verticalSmall,
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
              suffixStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            style: textTheme.titleMedium
                ?.merge(context.brandTheme.moneyTextStyle)
                .copyWith(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink),
          ),
        ),
        AppSpacers.verticalMedium,
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
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
