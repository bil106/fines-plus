import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/reminders/presentation/screens/reminders_screen.dart' show EmptyStateIcon;
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_recaptcha_v2/flutter_easy_recaptcha_v2.dart';
import 'package:intl/intl.dart';

/// Штрафи tab - a results list + refresh action, not the old "enter plate
/// and check" form (that flow's plate/tech-passport were already captured
/// during car setup, so CarInfoCubit already knows them; see checkFines
/// below). Reads from HistoryCubit, the same source FinesAlertCard on the
/// dashboard uses, instead of the dead FinesCubit/FinesRepository stack
/// this replaces.
@RoutePage()
class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  bool _showRecaptcha = false;

  void _refresh() {
    setState(() => _showRecaptcha = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).fines, style: Theme.of(context).textTheme.titleLarge),
                            if (state is HistoryLoaded && state.history.isNotEmpty)
                              Text(
                                _checkedAtLabel(context, state.history.first.checkedAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: state is HistoryLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        onPressed: state is HistoryLoading ? null : _refresh,
                      ),
                    ],
                  ),
                ),
                if (_showRecaptcha)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                      child: RecaptchaV2(
                        apiKey: Env.recaptchaSiteKey,
                        onVerifiedSuccessfully: (token) {
                          setState(() => _showRecaptcha = false);
                          context.read<CarInfoCubit>().checkFinesWithCaptcha(token);
                        },
                      ),
                    ),
                  ),
                Expanded(child: _Body(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }

  String _checkedAtLabel(BuildContext context, DateTime checkedAt) {
    final now = DateTime.now();
    final isToday = checkedAt.year == now.year && checkedAt.month == now.month && checkedAt.day == now.day;
    if (isToday) {
      return '${S.of(context).verif_date} ${S.of(context).today_at} ${DateFormat('HH:mm').format(checkedAt)}';
    }
    return '${S.of(context).verif_date} ${DateFormat('dd.MM.yyyy HH:mm').format(checkedAt)}';
  }
}

class _Body extends StatelessWidget {
  final HistoryState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is HistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HistoryError) {
      return Center(child: Text('${S.of(context).error} ${(state as HistoryError).message}'));
    }

    if (state is! HistoryLoaded || (state as HistoryLoaded).history.isEmpty) {
      return _EmptyFines();
    }

    final latest = (state as HistoryLoaded).history.first;
    final unpaid = <MapEntry<String, Map<String, dynamic>>>[];
    final paid = <MapEntry<String, Map<String, dynamic>>>[];

    for (final entry in latest.fines.asMap().entries) {
      final fineId = entry.value['id']?.toString() ?? '${entry.key}';
      final e = MapEntry(fineId, entry.value);
      if (latest.paidFines.contains(fineId)) {
        paid.add(e);
      } else {
        unpaid.add(e);
      }
    }

    final dueTotal = unpaid.fold<double>(0, (sum, e) => sum + _fineAmount(e.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.brandTheme.alertFg),
              ),
              Text(
                '${dueTotal.toStringAsFixed(0)} UAH',
                style: Theme.of(context).textTheme.headlineMedium?.merge(context.brandTheme.moneyTextStyle).copyWith(
                  color: context.brandTheme.alertFg,
                ),
              ),
            ],
          ),
        ),
        if (unpaid.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(S.of(context).unpaid_fines_section, style: Theme.of(context).textTheme.titleSmall),
          for (final e in unpaid) _FineRow(fineId: e.key, fine: e.value, historyDocId: latest.id, isPaid: false),
        ],
        if (paid.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(S.of(context).paid_fines_section, style: Theme.of(context).textTheme.titleSmall),
          for (final e in paid) _FineRow(fineId: e.key, fine: e.value, historyDocId: latest.id, isPaid: true),
        ],
      ],
    );
  }
}

double _fineAmount(Map<String, dynamic> fine) {
  final raw = fine['amount'] ?? fine['suma'] ?? fine['penalty'] ?? fine['total'] ?? 0;
  return double.tryParse(raw.toString()) ?? 0;
}

String _fineDescription(Map<String, dynamic> fine) {
  return (fine['description'] ?? fine['article'] ?? fine['offense'] ?? fine['violation'] ?? '').toString();
}

String _fineDate(Map<String, dynamic> fine) {
  return (fine['date'] ?? fine['violationDate'] ?? fine['datetime'] ?? '').toString();
}

class _FineRow extends StatelessWidget {
  final String fineId;
  final Map<String, dynamic> fine;
  final String historyDocId;
  final bool isPaid;

  const _FineRow({required this.fineId, required this.fine, required this.historyDocId, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final amount = _fineAmount(fine);
    final description = _fineDescription(fine);
    final date = _fineDate(fine);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: context.brandTheme.surfaceBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isPaid) const Icon(Icons.check_circle, color: Colors.green, size: 20),
          if (isPaid) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) Text(description, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '${amount.toStringAsFixed(0)} UAH${date.isNotEmpty ? ' · $date' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (!isPaid)
            ElevatedButton(
              onPressed: () => context.read<HistoryCubit>().markFineAsPaid(historyDocId, fineId, true),
              child: Text(S.of(context).pay),
            ),
        ],
      ),
    );
  }
}

class _EmptyFines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyStateIcon(),
            const SizedBox(height: 16),
            Text(S.of(context).no_fines, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
