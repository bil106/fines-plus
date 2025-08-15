import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/car_info_cubit.dart';
import 'package:core_cubit/cubit/car_info_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final ValueChanged<String>? onCheckFine;
  const CarInfoScreen({super.key, this.onCheckFine});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CarInfoCubit(context.read<CarInfoRepository>()),
      child: _CarInfoView(onCheckFine: onCheckFine),
    );
  }
}

class _CarInfoView extends StatefulWidget {
  final ValueChanged<String>? onCheckFine;
  const _CarInfoView({this.onCheckFine});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    final cubit = context.read<CarInfoCubit>();
    cubit.stream.listen((state) {
      _carNumberController.text = state.carNumber;
      _techPassportController.text = state.techPassport;
    });
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarInfoCubit>();
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacers.verticalXLarge,
              Text(S.of(context).addition_cars, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              AppSpacers.verticalHuge,
              Card(
                color: AppColors.neutreBlanc,
                shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).car_number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                      AppSpacers.verticalSmall,
                      TextField(
                        controller: _carNumberController,
                        onChanged: cubit.setCarNumber,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                        inputFormatters: [VehicleNumberFormatter(mapLatinToCyrillic: true)],
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        maxLength: 8,
                        decoration: InputDecoration(
                          hintText: 'АН0000НА',
                          hintStyle: const TextStyle(fontSize: 28, color: AppColors.neutreGrey),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                        ),
                      ),
                      AppSpacers.verticalLarge,
                      Text(S.of(context).reg_number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                      AppSpacers.verticalSmall,
                      TextField(
                        controller: _techPassportController,
                        onChanged: cubit.setTechPassport,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                        inputFormatters: [TechPassportFormatter()],
                        maxLength: 9,
                        decoration: InputDecoration(
                          hintText: 'ХЕ 128436',
                          hintStyle: const TextStyle(fontSize: 28, color: AppColors.neutreGrey),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacers.verticalLargeXL,
              BlocBuilder<CarInfoCubit, CarInfoState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: cubit.isFormValid
                          ? () {
                              final error = cubit.validate();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                return;
                              }

                              final carNumber = state.carNumber;

                             
                            

                              widget.onCheckFine?.call(carNumber);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue700,
                        shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                      ),
                      child: Text(S.of(context).search, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


   