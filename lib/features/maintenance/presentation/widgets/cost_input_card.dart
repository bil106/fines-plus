import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:core_utils/formatters/decimal_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CostInputCard extends StatelessWidget {
  final TextEditingController controller;

  const CostInputCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final settingsCubit = context.watch<SettingsCubit>();
    final settings = settingsCubit.state;

    final currencyLabel = settingsCubit.getCurrencyLabel(context, settings.currency);

    return Card(
      color: AppColors.neutreBlanc,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.radiusLarge,
        side: BorderSide(color: context.brandTheme.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary, size: 24),
            AppSpacers.horizontalSmallMedium,
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: const [DecimalInputFormatter()],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: S.of(context).enter_amount,
                  hintStyle: const TextStyle(fontSize: 15, color: AppColors.neutreGrey),
                ),
                style: textTheme.subtitleText
                    .merge(context.brandTheme.moneyTextStyle)
                    .copyWith(fontSize: 15, color: AppColors.ink),
                onChanged: (value) {
                  final input = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;

                  settingsCubit.currencyService.convert(
                    input,
                    "UAH",
                    fromCurrency: settings.currency,
                  );

                },
              ),
            ),
            Text(currencyLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
