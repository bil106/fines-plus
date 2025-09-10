import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/car_info/car_info_cubit.dart';
import 'package:core_cubit/cubit/car_info/car_info_state.dart';
import 'package:core_cubit/cubit/history/history_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/history_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_recaptcha_v2/flutter_easy_recaptcha_v2.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final void Function(String carNumber, String series, String number)? onCheckFine;
  final String initialCarNumber;
  const CarInfoScreen({super.key, this.onCheckFine, this.onBack, required this.initialCarNumber});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HistoryCubit(repository: context.read<HistoryRepository>())),
        BlocProvider(
          create: (context) => CarInfoCubit(context.read<CarInfoRepository>(), context.read<HistoryCubit>()),
        ),
      ],
      child: _CarInfoView(onCheckFine: onCheckFine, onBack: onBack),
    );
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

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    historyCubit = context.read<HistoryCubit>();
    carInfoCubit = context.read<CarInfoCubit>();

    carInfoCubit.loadSavedCarInfo().then((_) {
      _carNumberController.text = carInfoCubit.state.carNumber;
      _techPassportController.text = carInfoCubit.state.techPassport;
    });
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  void _onRecaptchaVerified(String token) {
    setState(() {
      _showRecaptcha = false;
    });
    carInfoCubit.checkFinesWithCaptcha(token);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: carInfoCubit,
      child: Scaffold(
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
                        Text(
                          S.of(context).car_number,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                        AppSpacers.verticalSmall,
                        TextField(
                          controller: _carNumberController,
                          onChanged: carInfoCubit.setCarNumber,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
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
                        Text(
                          S.of(context).reg_number,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                        AppSpacers.verticalSmall,
                        TextField(
                          controller: _techPassportController,
                          onChanged: carInfoCubit.setTechPassport,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
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

                BlocConsumer<CarInfoCubit, CarInfoState>(
                  listener: (context, state) {
                    if (state.status is CarInfoErrorStatus) {
                      final msg = (state.status as CarInfoErrorStatus).message;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    } else if (state.status is CarInfoLoadedStatus) {
                      final carNumber = state.carNumber;

                      final homeWrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      homeWrapperState?.openPage(HomePage.history);

                      if (widget.onCheckFine != null) {
                        final parts = carInfoCubit.getTechPassportParts();
                        widget.onCheckFine!(carNumber, parts['series']!, parts['number']!);
                      }
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state.status is CarInfoLoadingStatus;

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: carInfoCubit.isFormValid && !isLoading
                                ? () => setState(() => _showRecaptcha = true)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue700,
                              shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(S.of(context).search, style: textTheme.buttonText),
                          ),
                        ),
                        if (_showRecaptcha)
                          SizedBox(
                            height: 500,
                            child: RecaptchaV2(
                              apiKey: Env.recaptchaSiteKey,
                              onVerifiedSuccessfully: _onRecaptchaVerified,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                AppSpacers.verticalLargeXL,
                const AdBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
