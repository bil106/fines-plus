import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
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
/// (config.finesCheckEnabled), or when there's no check yet, or the latest
/// check came back clean - same gating CarCubit.checkFines already applies.
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
          if (latest.paidFines.contains(fineId)) continue;
          unpaidCount++;
          final raw = entry.value['amount'] ?? entry.value['suma'] ?? entry.value['penalty'];
          if (raw is num) {
            unpaidTotal += raw;
          } else if (raw != null) {
            unpaidTotal += num.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          }
        }

        if (unpaidCount == 0) return const SizedBox.shrink();

        final settingsCubit = context.watch<SettingsCubit>();
        final currency = settingsCubit.state.currency;
        final currencyService = context.read<CurrencyService>();
        final converted = currencyService.convert(unpaidTotal.toDouble(), currency, fromCurrency: S.of(context).grn);

        final locale = Localizations.localeOf(context).languageCode;
        final title = locale == 'uk' ? _unpaidFinesLabelUk(unpaidCount) : _unpaidFinesLabelEn(unpaidCount);

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppBorders.radiusMedium,
              onTap: () => context.findAncestorStateOfType<HomeScreenWrapperState>()?.openPage(HomePage.history),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.alertBg,
                  border: Border.all(color: AppColors.alertBorder),
                  borderRadius: AppBorders.radiusMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.alertFg),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${converted.toStringAsFixed(0)} $currency',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

String _unpaidFinesLabelEn(int n) => n == 1 ? '1 unpaid fine' : '$n unpaid fines';
