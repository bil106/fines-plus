import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/unauthorized_dialog.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import '../../../../../env/env.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_recaptcha_v2/flutter_easy_recaptcha_v2.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final void Function(String carNumber, String series, String number)? onCheckFine;

  const CarInfoScreen({super.key, this.onCheckFine, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _CarInfoView(onCheckFine: onCheckFine, onBack: onBack);
  }
}

class _CarInfoView extends StatefulWidget {
  final void Function(String carNumber, String series, String number)? onCheckFine;
  final VoidCallback? onBack;

  const _CarInfoView({this.onCheckFine, this.onBack});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;
  bool _showRecaptcha = false;

  late final CarCubit carCubit;

  final _carReg = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$');
  final _techReg = RegExp(r'^[А-ЯІЇЄҐ]{3}\d{6}$');

  bool get isFormValid =>
      _carReg.hasMatch(_carNumberController.text) && _techReg.hasMatch(_techPassportController.text);

  bool get hasCar => carCubit.state.carNumber.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    carCubit = context.read<CarCubit>();

    _carNumberController.text = carCubit.state.carNumber;
    _techPassportController.text = carCubit.state.techPassport;

   _carNumberController.addListener(() {
      final newNumber = _carNumberController.text;
      carCubit.changeCar(newNumber); 
      context.read<CarInfoCubit>().setCarNumber(newNumber); 
      setState(() {}); 
    });

    _techPassportController.addListener(() {
      carCubit.setTechPassport(_techPassportController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  void _onRecaptchaVerified(String token) async {
    if (!mounted) return;
    setState(() => _showRecaptcha = false);

    await carCubit.checkFines(token);

    final carNumber = carCubit.state.carNumber;
    if (carNumber.isNotEmpty) {
      context.read<AnalyticsCubit>().loadForCurrentCar();
      context.read<ExpensesCubit>().loadExpensesForCar(carNumber);
    }

    if (widget.onCheckFine != null) {
      final parts = carCubit.getTechPassportParts();
      widget.onCheckFine!(carNumber, parts['series']!, parts['number']!);
    }
  }

  void _handleUnauthorized() {
    showDialog(
      context: context,
      builder: (_) => UnauthorizedDialog(
        onLogin: () {
          Navigator.of(context).pop();
          context.router.push(RegistrationRoute());
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).delete_car_number),
        content: Text(S.of(context).delete_cars_confirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCars();
            },
            child: Text(S.of(context).delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCars() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _handleUnauthorized();
      return;
    }

    context.read<StatisticsCubit>().clearStats();

    context.read<AnalyticsCubit>().stopListeningToCar();
    context.read<AnalyticsCubit>().clear();

    context.read<ExpensesCubit>().clearExpensesForCar();
    context.read<HistoryCubit>().clear();

    await context.read<CarInfoCubit>().deleteCurrentCar();

    _carNumberController.clear();
    _techPassportController.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).cars_deleted_success)));
    if (!mounted) return;
    if (carCubit.state.carNumber.isEmpty) {
      context.router.replaceAll([const HomeRoute()]);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () => Navigator.pop(context)),
      ),
      backgroundColor: AppColors.energyBlue50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacers.verticalXLarge,
              Text(S.of(context).addition_cars, style: textTheme.title),
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
                      Text(S.of(context).car_number, style: textTheme.carNumber),
                      AppSpacers.verticalSmall,
                      TextField(
                        controller: _carNumberController,
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
                      AppSpacers.verticalLarge,
                      Text(S.of(context).reg_number, style: textTheme.carNumber),
                      AppSpacers.verticalSmall,
                      TextField(
                        controller: _techPassportController,
                        style: textTheme.black28W400,
                        inputFormatters: [TechPassportFormatter()],
                        maxLength: 9,
                        decoration: InputDecoration(
                          hintText: S.of(context).hint_tech_data_num,
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
              ),
              AppSpacers.verticalLargeXL,
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: isFormValid
                          ? () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                _handleUnauthorized();
                              } else {
                                setState(() => _showRecaptcha = true);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue700,
                        shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                      ),
                      child: Text(S.of(context).search, style: textTheme.buttonText),
                    ),
                  ),
                  if (_showRecaptcha)
                    SizedBox(
                      height: 500,
                      child: RecaptchaV2(apiKey: Env.recaptchaSiteKey, onVerifiedSuccessfully: _onRecaptchaVerified),
                    ),
                  TextButton(
                    onPressed: hasCar ? () => _showDeleteDialog(context) : null,
                    child: Text(
                      S.of(context).delete_car_number,
                      style: textTheme.bodyMedium?.copyWith(color: hasCar ? AppColors.red : AppColors.neutreGrey),
                    ),
                  ),
                ],
              ),
              AppSpacers.verticalLargeXL,
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
