import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/unauthorized_dialog.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_state.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_recaptcha_v2/flutter_easy_recaptcha_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final void Function(String carNumber, String series, String number)? onCheckFine;
  final VoidCallback? onBack;
  const _CarInfoView({this.onCheckFine, this.onBack});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  late final HistoryCubit historyCubit;
  late final CarInfoCubit carInfoCubit;

  bool _showRecaptcha = false;

  final _carReg = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$');
  final _techReg = RegExp(r'^[А-ЯІЇЄҐ]{3}\d{6}$');

  bool get isFormValid =>
      _carReg.hasMatch(_carNumberController.text) && _techReg.hasMatch(_techPassportController.text);

  @override
  void initState() {
    super.initState();

    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    historyCubit = context.read<HistoryCubit>();
    carInfoCubit = context.read<CarInfoCubit>();

    carInfoCubit.loadSavedCarInfo().then((_) {
      if (!mounted) return;
      _carNumberController.text = carInfoCubit.state.carNumber;
      _techPassportController.text = carInfoCubit.state.techPassport;

      historyCubit.loadHistory(carInfoCubit.state.carNumber);

      setState(() {});
    });

    _carNumberController.addListener(() => setState(() {}));
    _techPassportController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  void _onRecaptchaVerified(String token) {
    setState(() => _showRecaptcha = false);
    carInfoCubit.checkFinesWithCaptcha(token);
  }

  void _navigateToRegistration() {
    final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
    homeState?.openPage(HomePage.registration);
  }

  void _handleUnauthorized() {
    showDialog(
      context: context,
      builder: (_) => UnauthorizedDialog(onLogin: _navigateToRegistration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () => Navigator.pop(context)),
      ),
      backgroundColor: AppColors.grey50,
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
                        onChanged: carInfoCubit.setCarNumber,
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
                        onChanged: carInfoCubit.setTechPassport,
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
              BlocListener<CarInfoCubit, CarInfoState>(
                listenWhen: (prev, curr) => prev.status != curr.status,
                listener: (context, state) async {
                  if (state.status is CarInfoErrorStatus) {
                    final msg = (state.status as CarInfoErrorStatus).message;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(S.of(context).error),
                          content: Text(msg),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).ok))],
                        ),
                      );
                    });
                  } else if (state.status is CarInfoLoadedStatus) {
                    final carInfoCubit = context.read<CarInfoCubit>();
                    final carNumber = carInfoCubit.state.carNumber;
                    final techPassport = carInfoCubit.state.techPassport;

                    context.read<ExpensesCubit>().watch(carNumber, techPassport);

                    historyCubit.loadHistory(carNumber);

                    await context.read<MaintenanceCubit>().syncExpensesFromFirestore();

                    final homeWrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                    homeWrapperState?.openPage(HomePage.maintenance);

                    if (widget.onCheckFine != null) {
                      final parts = carInfoCubit.getTechPassportParts();
                      widget.onCheckFine!(carNumber, parts['series']!, parts['number']!);
                    }
                  } else if (state.status is CarInfoUnauthorizedStatus) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _handleUnauthorized();
                    });
                  }
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: isFormValid
                            ? () async {
                                final prefs = await SharedPreferences.getInstance();
                                final finesEnabled = prefs.getBool("finesCheck") ?? true;

                                if (!finesEnabled) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(S.of(context).fine_checking_disabled)));
                                  return;
                                }

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
                        child: carInfoCubit.state.status is CarInfoLoadingStatus
                            ? const CircularProgressIndicator(color: AppColors.neutreBlanc)
                            : Text(S.of(context).search, style: textTheme.buttonText),
                      ),
                    ),
                    if (_showRecaptcha)
                      SizedBox(
                        height: 500,
                        child: RecaptchaV2(apiKey: Env.recaptchaSiteKey, onVerifiedSuccessfully: _onRecaptchaVerified),
                      ),
                  ],
                ),
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
