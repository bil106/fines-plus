import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/home/domain/entities/last_event_ui_model.dart';
import 'package:fines_plus/features/settings/presentation/cubit/currency_stream.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LastEventCardAction extends StatelessWidget {
  final LastEventUiModel? event;
  final VoidCallback? onTap;
  final VoidCallback? onOpenEvents;

  const LastEventCardAction({super.key, this.event, this.onTap, this.onOpenEvents});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (event == null) {
      return _buildCard(
        child: Center(
          child: Text(S.of(context).no_recent_events, style: textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _buildHeader(context, textTheme),
            const Divider(height: 4, thickness: 1),
            _buildContent(textTheme, context),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Center(
                child: TextButton(
                  onPressed: onOpenEvents,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    S.of(context).open_events,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(S.of(context).last_event, style: textTheme.titleMedium),
        Text(event!.date, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContent(TextTheme textTheme, BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();

    return Row(
      children: [
        event!.icon,
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(event!.description, style: textTheme.black18W400),
                if (event!.mileage != null)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 9.0, top: 0),
                        child: StreamBuilder<double>(
                          stream: CurrencyStream(settingsCubit).convertedAmountStream(event!),
                          initialData: event!.amountOriginal ?? event!.amountValue,
                          builder: (context, snapshot) {
                            final convertedValue = snapshot.data ?? 0;
                            final displayCurrency = settingsCubit.getCurrencyLabel(
                              context,
                              settingsCubit.state.currency,
                            );
                            return Text(
                              "${convertedValue.toStringAsFixed(0)} $displayCurrency",
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueAccent,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 49.0, top: 0),
                        child: Text(
                          "${event!.mileage!.toStringAsFixed(0)} ${settingsCubit.state.unit}",
                          style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), child: child),
    );
  }
}
