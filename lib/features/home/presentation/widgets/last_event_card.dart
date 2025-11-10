import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';

import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LastEventCardAction extends StatelessWidget {
  final Expense? lastEvent;
  final VoidCallback? onTap;
  final VoidCallback? onOpenEvents;

  const LastEventCardAction({super.key, this.lastEvent, this.onTap, this.onOpenEvents});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (lastEvent == null) {
      return _buildCard(
        child: Center(
          child: Text("No recent events", style: textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context).last_event, style: textTheme.black16),
                Text(
                  DateFormat('dd MMM yyyy').format(lastEvent!.date),
                  style: textTheme.black14bold,
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 1, color: Colors.black26),
            const SizedBox(height: 10),

            _buildContent(lastEvent!, context, textTheme),
           

            Center(
              child: TextButton(
                onPressed: onOpenEvents,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(S.of(context).open_events, style: textTheme.black18bold.copyWith(color: AppColors.darkBlue),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Expense event, BuildContext context, TextTheme textTheme) {
    Widget icon;
    String description;
    String amountText = "${event.amount} ${event.currency}";

    switch (event.category) {
      case ExpenseCategory.fuel:
        icon = const Icon(Icons.local_gas_station, color: AppColors.redAccent, size: 50);
        description = "${event.comment ?? 'Fuel'} / ${event.fuelVolume?.toInt() ?? 0}L";
        break;
      case ExpenseCategory.service:
        icon = const Icon(Icons.build, color: AppColors.blue700, size: 50);
        description = event.comment ?? "Service";
        break;
      case ExpenseCategory.tuning:
        icon = Image.asset('assets/icons/tuning.jpg', height: 50, width: 50);
        description = event.comment ?? "Tuning";
        break;
      case ExpenseCategory.carWash:
        icon = const Icon(Icons.local_car_wash, color: AppColors.energyBlue, size: 50);
        description = event.comment ?? "Car Wash";
        break;
      case ExpenseCategory.other:
        icon = const Icon(Icons.event_note, size: 50, color: Colors.grey);
        description = event.comment ?? "Other";
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 80),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: textTheme.historyText),
              const SizedBox(height: 4),
              Text(amountText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
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
      child: Padding(padding: const EdgeInsets.only(left: 14, right: 14, top: 14), child: child),
    );
  }
}
