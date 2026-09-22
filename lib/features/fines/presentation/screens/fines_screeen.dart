import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/fines/domain/fines_check_reminder.dart';
import 'package:fines_plus/features/fines/domain/fines_diff.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/webview/presentation/screens/mvs_fines_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Штрафи tab - a results list + refresh action, not the old "enter plate
/// and check" form (that flow's plate/tech-passport were already captured
/// during car setup, so CarCubit already knows them). Reads from HistoryCubit, the same source FinesAlertCard on the
/// dashboard uses, instead of the dead FinesCubit/FinesRepository stack
/// this replaces.
@RoutePage()
class FinesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const FinesScreen({super.key, this.onBack});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  Future<void> _refresh() async {
    final carCubit = context.read<CarCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final reminder = FinesCheckReminder(context.read<PushHelper>());
    final messenger = ScaffoldMessenger.of(context);
    final l10n = S.of(context);

    final blocker = await carCubit.finesCheckBlocker();
    if (!mounted) return;
    if (blocker != null) {
      messenger.showSnackBar(SnackBar(content: Text(blocker)));
      return;
    }

    final historyBefore = historyCubit.state;
    final lastCheck =
        historyBefore is HistoryLoaded && historyBefore.history.isNotEmpty
        ? historyBefore.history.first
        : null;
    if (lastCheck != null &&
        _isToday(lastCheck.checkedAt) &&
        !await _confirmRecheck())
      return;
    if (!mounted) return;

    final fines = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (_) => MvsFinesWebView(
          plate: carCubit.state.carNumber,
          document: carCubit.state.techPassport,
        ),
      ),
    );
    if (fines == null) return;
    await carCubit.saveCheckedFines(fines);
    await reminder.rescheduleFromNow(l10n);

    final newCount = FinesDiff.newUnpaidCount(
      fines,
      FinesDiff.unpaidIds(lastCheck),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          newCount > 0 ? l10n.fines_new_found(newCount) : l10n.fines_no_new,
        ),
      ),
    );
  }

  /// Every check makes the user solve a captcha, so a second one on the same
  /// day is confirmed first.
  Future<bool> _confirmRecheck() async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.fines_recheck_title),
        content: Text(l10n.fines_recheck_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.fines_recheck_confirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      AppBackButton(onPressed: widget.onBack),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).fines,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            if (state is HistoryLoaded &&
                                state.history.isNotEmpty)
                              Text(
                                _checkedAtLabel(
                                  context,
                                  state.history.first.checkedAt,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).refreshIndicatorSemanticLabel,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.neutreBlanc,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          side: BorderSide(
                            color: context.brandTheme.surfaceBorder,
                          ),
                          shape: const CircleBorder(),
                          minimumSize: const Size(34, 34),
                        ),
                        iconSize: 16,
                        icon: state is HistoryLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        onPressed: state is HistoryLoading ? null : _refresh,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _Body(state: state, onRefresh: _refresh),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _checkedAtLabel(BuildContext context, DateTime checkedAt) {
    if (_isToday(checkedAt)) {
      return '${S.of(context).fines_checked} ${S.of(context).today_at} ${DateFormat('HH:mm').format(checkedAt)}';
    }
    return '${S.of(context).fines_checked} ${DateFormat('dd.MM.yyyy HH:mm').format(checkedAt)}';
  }
}

class _Body extends StatelessWidget {
  final HistoryState state;
  final VoidCallback onRefresh;
  const _Body({required this.state, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (state is HistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HistoryError) {
      return Center(
        child: Text(
          '${S.of(context).error} ${(state as HistoryError).message}',
        ),
      );
    }

    if (state is! HistoryLoaded || (state as HistoryLoaded).history.isEmpty) {
      return _EmptyFines(onRefresh: onRefresh);
    }

    final latest = (state as HistoryLoaded).history.first;
    if (latest.fines.isEmpty) return _EmptyFines(onRefresh: onRefresh);
    final unpaid = <MapEntry<String, Map<String, dynamic>>>[];
    final paid = <MapEntry<String, Map<String, dynamic>>>[];

    for (final entry in latest.fines.asMap().entries) {
      final fineId = entry.value['id']?.toString() ?? '${entry.key}';
      final e = MapEntry(fineId, entry.value);
      if (latest.isFinePaid(fineId, entry.value)) {
        paid.add(e);
      } else {
        unpaid.add(e);
      }
    }

    final dueTotal = unpaid.fold<double>(
      0,
      (sum, e) => sum + _fineAmount(e.value),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.brandTheme.alertBg,
            border: Border.all(color: context.brandTheme.alertBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).due_amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.brandTheme.alertFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Text(
                _money(context, dueTotal),
                style: Theme.of(context).textTheme.headlineMedium
                    ?.merge(context.brandTheme.moneyTextStyle)
                    .copyWith(color: context.brandTheme.alertFg, fontSize: 24),
              ),
            ],
          ),
        ),
        if (unpaid.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            S.of(context).unpaid_fines_section,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          for (final e in unpaid)
            _FineRow(
              fineId: e.key,
              fine: e.value,
              historyDocId: latest.id,
              isPaid: false,
            ),
        ],
        if (paid.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            S.of(context).paid_fines_section,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          for (final e in paid)
            _FineRow(
              fineId: e.key,
              fine: e.value,
              historyDocId: latest.id,
              isPaid: true,
            ),
        ],
      ],
    );
  }
}

double _fineAmount(Map<String, dynamic> fine) {
  final raw =
      fine['amount'] ?? fine['suma'] ?? fine['penalty'] ?? fine['total'] ?? 0;
  return double.tryParse(raw.toString()) ?? 0;
}

String _fineDescription(Map<String, dynamic> fine) {
  return (fine['description'] ??
          fine['article'] ??
          fine['offense'] ??
          fine['violation'] ??
          '')
      .toString();
}

String _fineDate(Map<String, dynamic> fine) {
  return (fine['date'] ?? fine['violationDate'] ?? fine['datetime'] ?? '')
      .toString();
}

String _money(BuildContext context, double amount) =>
    '${NumberFormat('#,##0.##', Localizations.localeOf(context).toString()).format(amount)} UAH';

class _FineRow extends StatelessWidget {
  final String fineId;
  final Map<String, dynamic> fine;
  final String historyDocId;
  final bool isPaid;

  const _FineRow({
    required this.fineId,
    required this.fine,
    required this.historyDocId,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    final amount = _fineAmount(fine);
    final description = _fineDescription(fine);
    final paidAt = isPaid ? fine['paidAt']?.toString() : null;
    final rawDate = paidAt ?? _fineDate(fine);
    final parsedDate = DateTime.tryParse(rawDate);
    final date = parsedDate == null
        ? rawDate
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).format(parsedDate);
    const muted = AppColors.textSecondary;
    final theme = Theme.of(context).textTheme;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty)
          Text(
            description,
            style: theme.bodyLarge?.copyWith(
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: isPaid ? muted : AppColors.ink,
            ),
          ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${paidAt != null ? S.of(context).paid : S.of(context).fines_violation} $date',
            style: theme.bodySmall?.copyWith(fontSize: 11.5, color: muted),
          ),
        ],
      ],
    );
    final trailing = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _money(context, amount),
          style: theme.titleMedium
              ?.merge(context.brandTheme.moneyTextStyle)
              .copyWith(
                fontSize: isPaid ? 14 : 15,
                fontWeight: isPaid ? FontWeight.w700 : FontWeight.w800,
                color: isPaid ? muted : context.brandTheme.alertFg,
              ),
        ),
        if (!isPaid) ...[
          const SizedBox(height: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: AppColors.neutreBlanc,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              textStyle: theme.labelLarge?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              context.read<HistoryCubit>().markFineAsPaid(
                historyDocId,
                fineId,
                true,
              );
            },
            child: Text(S.of(context).pay),
          ),
        ],
      ],
    );
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.brandTheme.surfaceBg,
        border: Border.all(color: context.brandTheme.surfaceBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(16) > 20;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isPaid) ...[
                Icon(
                  Icons.check_circle_outline,
                  color: context.brandTheme.statusSuccess,
                  size: 18,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          details,
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: trailing,
                          ),
                        ],
                      )
                    : details,
              ),
              if (!stacked) ...[const SizedBox(width: 10), trailing],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFines extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyFines({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.catOther,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).fines_not_found_title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).fines_not_found_body,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.neutreBlanc,
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: context.brandTheme.surfaceBorder),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              onPressed: onRefresh,
              child: Text(S.of(context).fines_recheck_confirm),
            ),
          ],
        ),
      ),
    );
  }
}
