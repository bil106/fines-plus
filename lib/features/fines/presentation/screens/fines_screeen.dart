import 'package:core_data/core_data.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/reminders/presentation/screens/reminders_screen.dart'
    show EmptyStateIcon;
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
  // Temporary preview: disable with --dart-define=FINES_DEMO=false.
  // Release builds always use real history.
  static const demoEnabled =
      kDebugMode && bool.fromEnvironment('FINES_DEMO', defaultValue: true);
  final bool showDemo;
  final VoidCallback? onBack;
  const FinesScreen({super.key, this.showDemo = demoEnabled, this.onBack});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  bool _showRecaptcha = false;
  late DateTime _demoCheckedAt = DateTime.now();

  HistoryLoaded _demoHistory(BuildContext context) {
    final labels = S.of(context);
    return HistoryLoaded([
      FineHistory(
        id: 'demo',
        userId: '',
        carNumber: '',
        docSeries: '',
        docNumber: '',
        checkedAt: _demoCheckedAt,
        paidFines: const {'parking', 'signal'},
        fines: [
          {
            'id': 'speed',
            'description': labels.fines_demo_speed,
            'amount': 255,
            'date': '2026-09-02',
          },
          {
            'id': 'parking',
            'description': labels.fines_demo_parking,
            'amount': 510,
            'paidAt': '2026-08-18',
          },
          {
            'id': 'signal',
            'description': labels.fines_demo_signal,
            'amount': 1700,
            'paidAt': '2026-07-03',
          },
        ],
      ),
    ]);
  }

  void _refresh() {
    if (kDebugMode && widget.showDemo) {
      setState(() => _demoCheckedAt = DateTime.now());
      return;
    }
    setState(() => _showRecaptcha = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      body: SafeArea(
        child: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, liveState) {
            final demo = kDebugMode && widget.showDemo;
            final state = demo ? _demoHistory(context) : liveState;
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
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF191A1C),
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
                                    ?.copyWith(color: const Color(0xFF707070)),
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
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF207BD7),
                          side: BorderSide(
                            color: context.brandTheme.surfaceBorder,
                          ),
                          shape: const CircleBorder(),
                          minimumSize: const Size(44, 44),
                        ),
                        icon: state is HistoryLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
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
                if (_showRecaptcha)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: RecaptchaV2(
                        apiKey: Env.recaptchaSiteKey,
                        onVerifiedSuccessfully: (token) {
                          setState(() => _showRecaptcha = false);
                          context.read<CarInfoCubit>().checkFinesWithCaptcha(
                            token,
                          );
                        },
                      ),
                    ),
                  ),
                if (demo)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.of(context).fines_demo_label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF707070),
                      ),
                    ),
                  ),
                Expanded(
                  child: _Body(state: state, demo: demo),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _checkedAtLabel(BuildContext context, DateTime checkedAt) {
    final now = DateTime.now();
    final isToday =
        checkedAt.year == now.year &&
        checkedAt.month == now.month &&
        checkedAt.day == now.day;
    if (isToday) {
      return '${S.of(context).fines_checked} ${S.of(context).today_at} ${DateFormat('HH:mm').format(checkedAt)}';
    }
    return '${S.of(context).fines_checked} ${DateFormat('dd.MM.yyyy HH:mm').format(checkedAt)}';
  }
}

class _Body extends StatelessWidget {
  final HistoryState state;
  final bool demo;
  const _Body({required this.state, required this.demo});

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
      return _EmptyFines();
    }

    final latest = (state as HistoryLoaded).history.first;
    if (latest.fines.isEmpty) return _EmptyFines();
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

    final dueTotal = unpaid.fold<double>(
      0,
      (sum, e) => sum + _fineAmount(e.value),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.brandTheme.alertBg,
            border: Border.all(color: context.brandTheme.alertBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).due_amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.brandTheme.alertFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _money(context, dueTotal),
                style: Theme.of(context).textTheme.headlineMedium
                    ?.merge(context.brandTheme.moneyTextStyle)
                    .copyWith(color: context.brandTheme.alertFg, fontSize: 32),
              ),
            ],
          ),
        ),
        if (unpaid.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            S.of(context).unpaid_fines_section,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF707070),
            ),
          ),
          for (final e in unpaid)
            _FineRow(
              fineId: e.key,
              fine: e.value,
              historyDocId: latest.id,
              isPaid: false,
              demo: demo,
            ),
        ],
        if (paid.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            S.of(context).paid_fines_section,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF707070),
            ),
          ),
          for (final e in paid)
            _FineRow(
              fineId: e.key,
              fine: e.value,
              historyDocId: latest.id,
              isPaid: true,
              demo: demo,
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
  final bool demo;

  const _FineRow({
    required this.fineId,
    required this.fine,
    required this.historyDocId,
    required this.isPaid,
    required this.demo,
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
    final muted = const Color(0xFF707070);
    final theme = Theme.of(context).textTheme;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty)
          Text(
            description,
            style: theme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: isPaid ? muted : const Color(0xFF191A1C),
            ),
          ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${paidAt != null ? S.of(context).paid : S.of(context).fines_violation} $date',
            style: theme.bodySmall?.copyWith(fontSize: 14, color: muted),
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
                fontSize: 18,
                color: isPaid ? muted : context.brandTheme.alertFg,
              ),
        ),
        if (!isPaid) ...[
          const SizedBox(height: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207BD7),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              textStyle: theme.labelLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              if (demo) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).fines_demo_label)),
                );
                return;
              }
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.brandTheme.surfaceBg,
        border: Border.all(color: context.brandTheme.surfaceBorder),
        borderRadius: BorderRadius.circular(16),
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
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF79B58A),
                  size: 20,
                ),
                const SizedBox(width: 12),
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
              if (!stacked) ...[const SizedBox(width: 16), trailing],
            ],
          );
        },
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
