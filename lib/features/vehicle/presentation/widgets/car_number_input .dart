// ignore_for_file: file_names

import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarNumberInput extends StatelessWidget {
  final TextEditingController controller;
  const CarNumberInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CarCubit, CarState>(
      builder: (context, state) {
      
        controller.value = controller.value.copyWith(
          text: state.carNumber,
          selection: TextSelection.collapsed(offset: (state.carNumber).length),
        );

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
                  onChanged: (value) {
                    context.read<CarCubit>().changeCar(value);
                  },
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
      },
    );
  }
}
