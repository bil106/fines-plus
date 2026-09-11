import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:flutter/material.dart';



class DeleteExpenseDialog {
  static Future<ExpenseCategory?> selectCategory(BuildContext context) async {
    return showDialog<ExpenseCategory?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(S.of(context).delete_expense_history),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOption(ctx, Icons.build, S.of(context).service, ExpenseCategory.service),
                _buildOption(ctx, Icons.local_gas_station, S.of(context).fuel, ExpenseCategory.fuel),
                _buildOption(ctx, Icons.directions_car, S.of(context).car_wash, ExpenseCategory.carWash),
                _buildOption(ctx, Icons.settings_applications, S.of(context).tuning, ExpenseCategory.tuning),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title:  Text(S.of(context).del_all_expenses),
                  onTap: () => Navigator.pop(ctx, null),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOption(BuildContext ctx, IconData icon, String text, ExpenseCategory category) {
    return ListTile(leading: Icon(icon), title: Text(text), onTap: () => Navigator.pop(ctx, category));
  }

  static Future<bool> confirmDelete(BuildContext context, String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child:  Text(S.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:  Text(S.of(context).remove, style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

