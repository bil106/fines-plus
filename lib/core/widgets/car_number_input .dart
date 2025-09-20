// ignore_for_file: file_names

import 'package:core_cubit/cubit/car_info/car_info_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CarNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final CarInfoCubit cubit;
  const CarNumberInput({super.key, required this.controller, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).car_number, style: textTheme.black28W600),
            AppSpacers.verticalSmall,
            TextField(
              controller: controller,
              onChanged: cubit.setCarNumber,
              style: textTheme.black28W400,
              inputFormatters: [VehicleNumberFormatter(mapLatinToCyrillic: true)],
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: S.of(context).hint_auto_num,
                hintStyle: textTheme.hintText,
                counterText: '',
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
