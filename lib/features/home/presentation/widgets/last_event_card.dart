import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';

import 'package:fines_plus/features/home/domain/entities/last_event_ui_model.dart';

import 'package:flutter/material.dart';


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
            const SizedBox(height: 4),
           Container(height: 1, width: double.infinity, color: Colors.grey[300]),

            const SizedBox(height: 4),
            _buildContent(textTheme),
        Transform.translate(
              offset: const Offset(0, -5),
              child: Center(
                child: TextButton(
                  onPressed: onOpenEvents,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    S.of(context).open_events,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.darkBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )          ],
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

  Widget _buildContent(TextTheme textTheme) {
    return Row(
      children: [
        event!.icon,
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event!.description, style: textTheme.black18W400),
               
                Padding(
                  padding: const EdgeInsets.only(left: 49.0),
                  child: Text(event!.amount, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold,color: AppColors.blueAccent)),
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
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 1), child: child),
    );
  }
}
