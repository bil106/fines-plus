import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A row of the Reminders list. Manual reminders can be toggled, edited and
/// deleted; automatic ones (insurance, oil) are read-only.
class ReminderCard extends StatelessWidget {
  final ReminderItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ReminderCard({super.key, required this.item, this.onToggle, this.onDelete, this.onTap});

  String _title(BuildContext context, int? days) {
    final l10n = S.of(context);
    switch (item.kind) {
      case ReminderKind.manual:
        return item.manual!.title;
      case ReminderKind.insurance:
        return l10n.reminder_insurance_expires;
      case ReminderKind.oil:
        final km = item.remainingKm;
        final dateOverdue = days != null && days < 0;
        return (km != null && km > 0 && !dateOverdue) ? l10n.reminder_oil_in_km(km) : l10n.reminder_oil_due;
    }
  }

  String? _subtitle(BuildContext context) {
    final l10n = S.of(context);
    final due = item.dueDate;
    final date = due == null
        ? null
        : DateFormat('d MMM yyyy', Localizations.localeOf(context).toString()).format(due);
    if (item.kind == ReminderKind.oil) {
      final estimate = item.estimatedDays;
      if (estimate != null) {
        return estimate >= 14 ? l10n.reminder_approx_weeks((estimate / 7).round()) : l10n.reminder_approx_days(estimate);
      }
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final status = item.status(now);
    final days = item.daysLeft(now);
    final done = status == ReminderStatus.done;
    final overdue = status == ReminderStatus.overdue;
    final soon = status == ReminderStatus.soon;

    final brand = context.brandTheme;
    final accent = done ? brand.statusComplete
        : overdue ? brand.statusDanger
        : soon ? brand.statusInfo : Theme.of(context).colorScheme.primary;
    final statusText = done ? S.of(context).done
        : overdue ? S.of(context).reminder_overdue
        : soon ? S.of(context).reminder_soon
        : days == null ? '' : '$days ${S.of(context).days}';
    final statusWidget = Text(statusText, style: theme.bodySmall?.copyWith(
      fontSize: 13, fontWeight: FontWeight.w700,
      color: overdue ? brand.statusDanger : soon ? brand.statusWarning : AppColors.textSecondary));

    final manual = item.manual;
    final subtitle = _subtitle(context);
    final subtitleStyle = theme.bodySmall?.copyWith(fontSize: 13, color: AppColors.textSecondary);

    return Material(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.brandTheme.surfaceBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: LayoutBuilder(builder: (context, constraints) {
            final stacked = constraints.maxWidth < 300 || MediaQuery.textScalerOf(context).scale(16) > 20;
            return Row(
              children: [
                Semantics(
                  checked: done,
                  label: _title(context, days),
                  child: SizedBox.square(
                    dimension: 40,
                    child: IconButton(
                      onPressed: onToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: accent.withValues(alpha: 0.16), foregroundColor: accent,
                        disabledBackgroundColor: accent.withValues(alpha: 0.16), disabledForegroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: Icon(done ? Icons.check : Icons.circle, size: done ? 18 : 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title(context, days), style: theme.bodyLarge?.copyWith(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.inkSoft,
                      decoration: done ? TextDecoration.lineThrough : TextDecoration.none)),
                    if (manual != null && manual.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(manual.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: subtitleStyle),
                    ],
                    if (manual != null) ...[
                      const SizedBox(height: 2),
                      Text(DateFormat('d MMM yyyy · HH:mm', Localizations.localeOf(context).toString())
                        .format(item.dueDate!), style: subtitleStyle),
                    ] else if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: subtitleStyle),
                    ],
                    if (stacked) ...[const SizedBox(height: 8), statusWidget],
                  ],
                )),
                if (!stacked) ...[const SizedBox(width: 8), statusWidget],
                if (item.isManual)
                  PopupMenuButton<String>(
                    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (action) => action == 'edit' ? onTap?.call() : onDelete?.call(),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(S.of(context).edit)),
                      PopupMenuItem(value: 'delete', child: Text(S.of(context).delete, style: const TextStyle(color: AppColors.red))),
                    ],
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
