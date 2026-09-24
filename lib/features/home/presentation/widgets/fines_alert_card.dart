import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The dashboard's "unpaid fines" alert, from the Fines+OS mockup - unlike
/// the mockup's static example, this reads the real result of the user's
/// most recent government-portal check (HistoryCubit, already live-synced
/// from Firestore) rather than any new data plumbing.
///
/// Hidden entirely when this brand doesn't have the fines-check feature
/// (config.finesCheckEnabled) or when there's no check yet. A clean latest
/// check shows the green "no fines" state, otherwise the red unpaid card.
class FinesAlertCard extends StatelessWidget {
  const FinesAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    final finesCheckEnabled = context.watch<AppConfig>().finesCheckEnabled;
    if (!finesCheckEnabled) return const SizedBox.shrink();

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        if (state is! HistoryLoaded || state.history.isEmpty) {
          return const SizedBox.shrink();
        }

        // Most recent check only (list is ordered by checkedAt desc) - an
        // older check's fines may already be reflected/superseded by it.
        final latest = state.history.first;
        num unpaidTotal = 0;
        var unpaidCount = 0;
        for (final entry in latest.fines.asMap().entries) {
          final fineId = entry.value['id']?.toString() ?? '${entry.key}';
          if (latest.isFinePaid(fineId, entry.value)) continue;
          unpaidCount++;
          final raw =
              entry.value['amount'] ??
              entry.value['suma'] ??
              entry.value['penalty'];
          if (raw is num) {
            unpaidTotal += raw;
          } else if (raw != null) {
            unpaidTotal +=
                num.tryParse(
                  raw.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0;
          }
        }

        final settingsCubit = context.watch<SettingsCubit>();
        final currency = settingsCubit.state.currency;
        final currencyService = context.read<CurrencyService>();
        final converted = currencyService.convert(
          unpaidTotal.toDouble(),
          currency,
          fromCurrency: S.of(context).grn,
        );

        void onTap() => context
            .findAncestorStateOfType<HomeScreenWrapperState>()
            ?.openPage(HomePage.fines);

        if (unpaidCount == 0) return _NoFinesCard(onTap: onTap);

        final amount = '${converted.toStringAsFixed(0)} $currency';
        final locale = Localizations.localeOf(context).languageCode;
        final title = unpaidCount == 1
            ? S.of(context).fine_pdr_title(amount)
            : '${locale == 'uk' ? _unpaidFinesLabelUk(unpaidCount) : _unpaidFinesLabelEn(unpaidCount)}: $amount';
        return _UnpaidFinesCard(title: title, onTap: onTap);
      },
    );
  }
}

/// Green "no fines" state - unchanged look from before the unpaid redesign.
class _NoFinesCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NoFinesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fgColor = context.brandTheme.statusSuccess;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: context.brandTheme.statusSuccessBg,
              border: Border.all(color: AppColors.successCardBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check, size: 16, color: fgColor),
                const SizedBox(width: 6),
                Text(
                  S.of(context).no_fines_short,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: fgColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Red "unpaid fines" state: fine icon, "Штраф ПДР: 255 UAH" (or the count
/// and total when there are several) and a "Сплатити" call to action that
/// opens the fines screen. No Apple Pay / Google Pay marks until real
/// payment through a provider is wired up - those marks may only appear on
/// buttons that actually start that payment.
class _UnpaidFinesCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _UnpaidFinesCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brand = context.brandTheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: AppBorders.radius16,
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brand.alertBg,
              border: Border.all(color: brand.alertBorder),
              borderRadius: AppBorders.radius16,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: brand.alertFg,
                    borderRadius: AppBorders.radiusLarge,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.neutreBlanc,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        S.of(context).pay,
                        style: textTheme.bodyMedium?.copyWith(
                          color: brand.alertFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: brand.alertFg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _unpaidFinesLabelUk(int n) {
  final mod100 = n % 100;
  final mod10 = n % 10;
  if (mod10 == 1 && mod100 != 11) {
    return '$n неоплачений штраф';
  } else if (mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14)) {
    return '$n неоплачені штрафи';
  }
  return '$n неоплачених штрафів';
}

String _unpaidFinesLabelEn(int n) =>
    n == 1 ? '1 unpaid fine' : '$n unpaid fines';
