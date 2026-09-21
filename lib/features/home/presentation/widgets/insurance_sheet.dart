import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/presentation/reminder_status_tint.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kUkMonthsShort = [
  'січ', 'лют', 'бер', 'кві', 'тра', 'чер', 'лип', 'сер', 'вер', 'жов', 'лис', 'гру',
];

/// The dashboard's Страхування sheet content - logs a purchased policy
/// (InsuranceRecord) via MaintenanceCubit. Distinct from the older
/// InsuranceDetailSheet, which only creates a renewal *reminder* and has no
/// company/policy/cost fields - that sheet is unchanged and still used
/// elsewhere (see its own doc comment). Styled to match the Паливо/ТО
/// sheets - flat bordered field cards with an always-visible label, not
/// Material's floating-label OutlineInputBorder.
class InsuranceSheet extends StatefulWidget {
  const InsuranceSheet({super.key});

  @override
  State<InsuranceSheet> createState() => InsuranceSheetState();
}

class InsuranceSheetState extends State<InsuranceSheet> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController policyNumberController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode policyNumberFocusNode = FocusNode();
  final FocusNode costFocusNode = FocusNode();

  DateTime? validFrom;
  DateTime? validTo;

  @override
  void initState() {
    super.initState();
    // Prefill from the active car's most recent policy, same idea as Fuel
    // prefilling mileage from getLastKnownMileage() - lets the user see/
    // renew what's already on file instead of always starting blank.
    // Saving still appends a new InsuranceRecord (a renewal is its own
    // history entry, same as every other record type here).
    final records = context.read<MaintenanceCubit>().state.insuranceRecords;
    if (records.isNotEmpty) {
      // Pick by when it was actually saved (updatedAt), not validFrom - a
      // renewal that only edits validTo keeps the same validFrom as the
      // record it's replacing, so validFrom alone can't tell them apart.
      final latest = records.reduce((a, b) {
        final aTime = a.updatedAt;
        final bTime = b.updatedAt;
        if (aTime == null) return b;
        if (bTime == null) return a;
        return aTime.isAfter(bTime) ? a : b;
      });
      companyController.text = latest.company;
      policyNumberController.text = latest.policyNumber;
      validFrom = latest.validFrom;
      validTo = latest.validTo;
      costController.text = latest.cost.round().toString();
    }
  }

  @override
  void dispose() {
    companyController.dispose();
    policyNumberController.dispose();
    costController.dispose();
    policyNumberFocusNode.dispose();
    costFocusNode.dispose();
    super.dispose();
  }

  void save() {
    if (companyController.text.trim().isEmpty || validFrom == null || validTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).fill_date)));
      return;
    }

    final record = InsuranceRecord(
      company: companyController.text.trim(),
      policyNumber: policyNumberController.text.trim(),
      validFrom: validFrom!,
      validTo: validTo!,
      cost: double.tryParse(costController.text) ?? 0,
      currency: context.read<SettingsCubit>().state.currency,
      // Until Firestore hands back its own timestamp, so this record already
      // counts as the most recently saved policy.
      updatedAt: DateTime.now(),
    );

    context.read<MaintenanceCubit>().addInsuranceRecord(record);
    Navigator.of(context).pop(record);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? validFrom : validTo) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        validFrom = picked;
      } else {
        validTo = picked;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day} ${_kUkMonthsShort[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settings = context.watch<SettingsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldCard(
          label: S.of(context).insurance_company,
          child: TextField(
            controller: companyController,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => policyNumberFocusNode.requestFocus(),
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
          label: S.of(context).policy_number,
          child: TextField(
            controller: policyNumberController,
            focusNode: policyNumberFocusNode,
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
        Row(
          children: [
            Expanded(
              child: AppFieldCard(
                label: S.of(context).valid_from,
                child: InkWell(
                  onTap: () => _pickDate(isFrom: true),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDate(validFrom),
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.grey700),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFieldCard(
                label: S.of(context).valid_to,
                accent: validTo == null
                    ? null
                    : ReminderItem(id: '', kind: ReminderKind.insurance, dueDate: validTo).status(DateTime.now()).attentionTint,
                child: InkWell(
                  onTap: () => _pickDate(isFrom: false),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDate(validTo),
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.grey700),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppFieldCard(
          label: S.of(context).cost,
          child: TextField(
            controller: costController,
            focusNode: costFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
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
      ],
    );
  }
}
