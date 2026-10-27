import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/helpers/date_utils.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_sheet.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/presentation/reminder_status_tint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The dashboard's Страхування entry point: a car can hold several policies
/// (MTPL, casco, ...), so with any saved this lists them - tap one to edit or
/// delete it - plus a button to add another; with none it opens the blank
/// form directly.
Future<void> showInsurancePolicies(BuildContext context) {
  if (context.read<MaintenanceCubit>().state.insuranceRecords.isEmpty) {
    return showInsuranceForm(context);
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.brandTheme.surfaceBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _InsurancePoliciesSheet(),
  );
}

class _InsurancePoliciesSheet extends StatelessWidget {
  const _InsurancePoliciesSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: context.brandTheme.surfaceBorder,
                  borderRadius: AppBorders.radiusSmall,
                ),
              ),
            ),
            Text(
              S.of(context).insurance,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: BlocBuilder<MaintenanceCubit, MaintenanceState>(
                buildWhen: (previous, current) => previous.insuranceRecords != current.insuranceRecords,
                builder: (context, state) {
                  final records = [...state.insuranceRecords]..sort((a, b) => a.validTo.compareTo(b.validTo));
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _PolicyTile(record: records[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showInsuranceForm(context),
                icon: const Icon(Icons.add),
                label: Text(S.of(context).insurance_add_policy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final InsuranceRecord record;

  const _PolicyTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tint = ReminderItem(
      id: '',
      kind: ReminderKind.insurance,
      dueDate: record.validTo,
    ).status(DateTime.now()).attentionTint;
    final until = formatShortDate(record.validTo, Localizations.localeOf(context).toString(), withYear: true);
    final details = [
      if (record.policyNumber.isNotEmpty) record.policyNumber,
      '${S.of(context).valid_to} $until',
    ].join(' · ');

    return Material(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.radius16,
        side: BorderSide(color: context.brandTheme.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: AppBorders.radius16,
        onTap: () => showInsuranceForm(context, record: record),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: tint ?? context.brandTheme.statusSuccess),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
