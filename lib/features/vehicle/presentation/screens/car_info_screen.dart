import 'package:auto_route/auto_route.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_state.dart';
import 'package:fines_plus/features/vehicle/presentation/widgets/car_info_card.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final void Function(String carNumber, String series, String number)? onCheckFine;
  final String initialCarNumber;

  const CarInfoScreen({super.key, this.onCheckFine, this.onBack, required this.initialCarNumber});

  @override
  Widget build(BuildContext context) {
    return _CarInfoView(onCheckFine: onCheckFine, onBack: onBack);
  }
}

class _CarInfoView extends StatefulWidget {
  const _CarInfoView({this.onBack, void Function(String carNumber, String series, String number)? onCheckFine});

  final VoidCallback? onBack;

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  late final CarInfoCubit carInfoCubit;

  bool _loadingCarInfo = false;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    carInfoCubit = context.read<CarInfoCubit>();

    // Загружаем сохраненные данные
    carInfoCubit.loadSavedCarInfo().then((_) {
      if (!mounted) return;
      _carNumberController.text = carInfoCubit.state.carNumber;
      _techPassportController.text = carInfoCubit.state.techPassport;
      setState(() {});
    });

    // Обновление Cubit при изменении полей
    _carNumberController.addListener(() {
      carInfoCubit.setCarNumber(_carNumberController.text);
      setState(() {});
    });
    _techPassportController.addListener(() {
      carInfoCubit.setTechPassport(_techPassportController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  Future<void> _loadCarInfo() async {
    setState(() => _loadingCarInfo = true);
    try {
      await carInfoCubit.loadCarDetailsFromApi();
    } finally {
      if (mounted) setState(() => _loadingCarInfo = false);
    }
  }

  String getCarImage(Map<String, dynamic> data) {
    final brand = (data['brand'] ?? '').toString().toLowerCase();
    final model = (data['model'] ?? '').toString().toLowerCase().replaceAll(' ', '_');
    final color = 'red'; // для теста
    return 'assets/images/cars/${brand}_${model}_$color.png';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CarInfoCubit, CarInfoState>(
      builder: (context, state) {
        final carDetails = state.carDetails;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.grey50,
            leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () => Navigator.pop(context)),
          ),
          backgroundColor: AppColors.grey50,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (carDetails != null)
                    Center(child: Image.asset(getCarImage(carDetails), height: 150, fit: BoxFit.contain)),
                  AppSpacers.verticalSmall,
                  Text('Додавання авто', style: textTheme.title),
                  AppSpacers.verticalSmall,
                  Card(
                    color: AppColors.neutreBlanc,
                    shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Номер авто', style: textTheme.carNumber),
                          AppSpacers.verticalSmall,
                          TextField(
                            controller: _carNumberController,
                            style: textTheme.black28W400,
                            inputFormatters: [VehicleNumberFormatter(mapLatinToCyrillic: true)],
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            maxLength: 8,
                            decoration: InputDecoration(
                              hintText: 'Введіть номер авто',
                              hintStyle: textTheme.hintText,
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.grey50,
                              border: OutlineInputBorder(
                                borderRadius: AppBorders.radius18,
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          AppSpacers.verticalLarge,
                          Text('Номер техпаспорта', style: textTheme.carNumber),
                          AppSpacers.verticalSmall,
                          TextField(
                            controller: _techPassportController,
                            style: textTheme.black28W400,
                            inputFormatters: [TechPassportFormatter()],
                            maxLength: 9,
                            decoration: InputDecoration(
                              hintText: 'Введіть номер техпаспорта',
                              hintStyle: textTheme.hintText,
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.grey50,
                              border: OutlineInputBorder(
                                borderRadius: AppBorders.radius18,
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacers.verticalMedium,
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: carInfoCubit.isFormValid ? _loadCarInfo : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue700,
                        shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                      ),
                      child: _loadingCarInfo
                          ? const CircularProgressIndicator(color: AppColors.neutreBlanc)
                          : Text('Пошук', style: textTheme.buttonText),
                    ),
                  ),
                  AppSpacers.verticalMedium,
                  if (state.status is CarInfoErrorStatus)
                    Text((state.status as CarInfoErrorStatus).message, style: textTheme.red14W400),
                  if (carDetails != null) CarInfoCard(data: carDetails, textTheme: textTheme),
                  const AdBannerWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
