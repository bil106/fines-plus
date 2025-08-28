import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/car_info_cubit.dart';
import 'package:core_cubit/cubit/car_info_state.dart';
import 'package:core_cubit/cubit/history_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/history_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final void Function(String carNumber, String series, String number)? onCheckFine;

  const CarInfoScreen({super.key, this.onCheckFine});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HistoryCubit(repository: context.read<HistoryRepository>())),
        BlocProvider(
          create: (context) => CarInfoCubit(context.read<CarInfoRepository>(), context.read<HistoryCubit>()),
        ),
      ],
      child: _CarInfoView(onCheckFine: onCheckFine),
    );
  }
}

class _CarInfoView extends StatefulWidget {
  final void Function(String carNumber, String series, String number)? onCheckFine;
  const _CarInfoView({this.onCheckFine});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;
  late final HistoryCubit historyCubit;
  late final CarInfoCubit carInfoCubit;
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    historyCubit = context.read<HistoryCubit>();
    carInfoCubit = CarInfoCubit(context.read<CarInfoRepository>(), historyCubit);

    _loadSavedCarInfo();

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint("Ad failed: $error");
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    carInfoCubit.close();
    super.dispose();
  }

  Future<void> _loadSavedCarInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final carNumber = prefs.getString('carNumber') ?? '';
    final techPassport = prefs.getString('techPassport') ?? '';

    _carNumberController.text = carNumber;
    _techPassportController.text = techPassport;

    if (carNumber.isNotEmpty) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection("cars").doc(carNumber).set({
          "fcmToken": token,
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: carInfoCubit,
      child: Scaffold(
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
                            hintText: 'АН0000НА',
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
                            hintText: 'ХЕE128436',
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

                      homeWrapperState?.openHistoryPage();

                      if (widget.onCheckFine != null) {
                        final parts = carInfoCubit.getTechPassportParts();
                        widget.onCheckFine!(carNumber, parts['series']!, parts['number']!);
                      }
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state.status is CarInfoLoadingStatus;

                    return SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: carInfoCubit.isFormValid && !isLoading ? () => carInfoCubit.checkFines() : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue700,
                          shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(S.of(context).search, style: textTheme.buttonText),
                      ),
                    );
                  },
                ),
                AppSpacers.verticalLargeXL,
                if (_bannerAd != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
