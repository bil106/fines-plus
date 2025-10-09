import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/widgets/delete_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_cubit.dart';

import 'package:design_system/colors/app_colors.dart';


class DeleteExpensesButton extends StatelessWidget {
  const DeleteExpensesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_forever, color: AppColors.energyBlue),
      tooltip: S.of(context).delete_expense_history,
      onPressed: () async {
        final cubit = context.read<MaintenanceCubit>();
        final selectedCategory = await DeleteExpenseDialog.selectCategory(context);

        if (selectedCategory == null) {
          final confirmAll = await DeleteExpenseDialog.confirmDelete(
            context,
            S.of(context).delete_all_expenses,
            S.of(context).cannot_be_undone,
          );
          if (confirmAll == true) {
            await cubit.deleteAllExpenses();
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(S.of(context).all_exp_hist_deleted)));
          }
        } else {
          final confirm = await DeleteExpenseDialog.confirmDelete(
            context,
            '${S.of(context).remove} ${selectedCategory.name}?',
            S.of(context).cannot_be_undone,
          );
          if (confirm == true) {
            await cubit.deleteExpensesByCategory(selectedCategory);
            // ScaffoldMessenger.of(
            //   context,
            // ).showSnackBar(SnackBar(content: Text('${S.of(context).category_removed}${selectedCategory.name}')));
          }
        }
      },
    );
  }
}
