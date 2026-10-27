import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/feedback/app_haptics.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_bottom_sheet.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_qr_scanner_sheet.dart';
import 'package:fines_plus/features/maintenance/data/insurance_policy_lookup.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/presentation/reminder_status_tint.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:core_utils/formatters/decimal_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fines_plus/core/helpers/date_utils.dart';

/// Opens the policy form in a bottom sheet: blank for a new policy, filled
/// with [record] (plus a Delete button) to edit one.
Future<void> showInsuranceForm(BuildContext context, {InsuranceRecord? record}) {
  final formKey = GlobalKey<InsuranceSheetState>();
  return AppBottomSheet.show(
    context,
    title: record == null ? S.of(context).insurance_add_policy : S.of(context).insurance_edit_policy,
    contentBuilder: (_) => InsuranceSheet(key: formKey, record: record),
    saveLabel: S.of(context).save,
    onSave: () => formKey.currentState?.save(),
    footerBuilder: record?.id == null
        ? null
        : (context) => TextButton(
            onPressed: () => formKey.currentState?.confirmDelete(),
            child: Text(S.of(context).delete, style: TextStyle(color: context.brandTheme.statusDanger)),
          ),
  );
}

/// The dashboard's Страхування form - logs a purchased policy
/// (InsuranceRecord) via MaintenanceCubit, or edits [record]. Distinct from the older
/// InsuranceDetailSheet, which only creates a renewal *reminder* and has no
/// company/policy/cost fields - that sheet is unchanged and still used
/// elsewhere (see its own doc comment). Styled to match the Паливо/ТО
/// sheets - flat bordered field cards with an always-visible label, not
/// Material's floating-label OutlineInputBorder.
class InsuranceSheet extends StatefulWidget {
  /// The policy being edited; null to add a new one.
  final InsuranceRecord? record;

  const InsuranceSheet({super.key, this.record});

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
  String policyUrl = '';
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record == null) return;
    companyController.text = record.company;
    policyNumberController.text = record.policyNumber;
    validFrom = record.validFrom;
    validTo = record.validTo;
    policyUrl = record.policyUrl;
    // Keep cents if the saved cost has them (3500.50), no ".00" otherwise.
    costController.text = record.cost == record.cost.roundToDouble()
        ? record.cost.toStringAsFixed(0)
        : record.cost.toStringAsFixed(2);
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
      id: widget.record?.id,
      company: companyController.text.trim(),
      policyNumber: policyNumberController.text.trim(),
      validFrom: validFrom!,
      validTo: validTo!,
      cost: double.tryParse(costController.text) ?? 0,
      currency: context.read<SettingsCubit>().state.currency,
      policyUrl: policyUrl,
      updatedAt: DateTime.now(),
    );

    final cubit = context.read<MaintenanceCubit>();
    if (widget.record == null) {
      cubit.addInsuranceRecord(record);
    } else {
      cubit.updateInsuranceRecord(record);
    }
    Navigator.of(context).pop(record);
  }

  /// Reads the policy's QR code and fills in what the registry page knows -
  /// everything but the premium, which only the user has.
  Future<void> _scanPolicy() async {
    final qrValue = await showInsuranceQrScanner(context);
    if (qrValue == null || !mounted) return;
    setState(() => isScanning = true);
    final policy = await InsurancePolicyLookup().fetch(qrValue);
    if (!mounted) return;
    setState(() => isScanning = false);
    if (policy == null) {
      AppHaptics.error();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).insurance_scan_failed)));
      return;
    }
    AppHaptics.success();
    setState(() {
      companyController.text = policy.company;
      policyNumberController.text = policy.policyNumber;
      validFrom = policy.validFrom;
      validTo = policy.validTo;
      policyUrl = qrValue.trim();
    });
    costFocusNode.requestFocus();
    if (!policy.matchesPlate(context.read<CarCubit>().state.carNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).insurance_scan_plate_mismatch(policy.plate))),
      );
    }
  }

  Future<void> confirmDelete() async {
    final id = widget.record?.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(S.of(context).insurance_delete_confirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(S.of(context).cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(S.of(context).delete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final cubit = context.read<MaintenanceCubit>();
    Navigator.of(context).pop();
    await cubit.deleteSingleExpense(ExpenseCategory.insurance, id);
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
    return formatShortDate(date, Localizations.localeOf(context).toString(), withYear: true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settings = context.watch<SettingsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The QR leads to the Ukrainian MTSBU policy registry; other markets'
        // policies have no equivalent.
        if (context.watch<AppConfig>().market == 'UA') ...[
          OutlinedButton.icon(
            onPressed: isScanning ? null : _scanPolicy,
            icon: isScanning
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.qr_code_scanner),
            label: Text(S.of(context).insurance_scan_qr),
          ),
          const SizedBox(height: 14),
        ],
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
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 14),
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
            style: textTheme.titleMedium
                ?.merge(context.brandTheme.moneyTextStyle)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 14),
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
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.catOther),
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
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.catOther),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppFieldCard(
          label: S.of(context).cost,
          child: TextField(
            controller: costController,
            focusNode: costFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: const [DecimalInputFormatter()],
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
        if (policyUrl.isNotEmpty) ...[
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(policyUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(S.of(context).insurance_open_policy),
          ),
        ],
      ],
    );
  }
}
