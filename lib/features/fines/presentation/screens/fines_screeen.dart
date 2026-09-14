// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_text_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/safe_prefs.dart';
import 'package:fines_plus/core/extensions/unauthorized_dialog.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';

import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_recaptcha_v2/flutter_easy_recaptcha_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class FinesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(String carNumber, String series, String number)? onFineCheck;

  const FinesScreen({super.key, this.onBack, this.onFineCheck});

  static final _carReg = RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$');
  static final _techReg = RegExp(r'^[A-Z]{3}\d{6}$');

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  bool _showRecaptcha = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final carInfoCubit = context.read<CarInfoCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
          elevation: 0,
        ),
        body: SafeArea(
          child: BlocListener<CarInfoCubit, CarInfoState>(
            listener: (context, state) {
              if (state.status is CarInfoLoadedStatus) {
                final carNumber = state.carNumber;
                final homeWrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                homeWrapperState?.openPage(HomePage.history);

                if (widget.onFineCheck != null) {
                  final parts = carInfoCubit.getTechPassportParts();
                  widget.onFineCheck!(carNumber, parts['series']!, parts['number']!);
                }
              } else if (state.status is CarInfoUnauthorizedStatus) {
                showDialog(
                  context: context,
                  builder: (_) => UnauthorizedDialog(
                    onLogin: () {
                      final homeWrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      homeWrapperState?.openPage(HomePage.registration);
                    },
                  ),
                );
              } else if (state.status is CarInfoErrorStatus) {
                final msg = (state.status as CarInfoErrorStatus).message;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(S.of(context).error),
                    content: Text(msg),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).ok))],
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppSpacers.verticalGigantic,
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(color: AppColors.energyBlue50, borderRadius: BorderRadius.circular(50)),
                    alignment: Alignment.center,
                    child: Image.asset('assets/icons/ic_launcher_foreground.png'),
                  ),
                  AppSpacers.verticalMassive,

                  BlocBuilder<CarCubit, CarState>(
                    builder: (context, carState) {
                      return BlocBuilder<CarInfoCubit, CarInfoState>(
                        builder: (context, state) {
                          final carNumber = state.carNumber;
                          final isLoading = state.status is CarInfoLoadingStatus;

                          final isCarNumberValid = carNumber.isNotEmpty && FinesScreen._carReg.hasMatch(carNumber);
                          final isFormValid = isCarNumberValid && !isLoading;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 65,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blue700,
                                    shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                                  ),
                                  onPressed: isFormValid
                                      ? () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          final finesEnabled = prefs.getBoolSafe("finesCheck", defaultValue: true);

                                          if (!finesEnabled) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(S.of(context).fine_checking_disabled)),
                                            );
                                            return;
                                          }

                                          final user = FirebaseAuth.instance.currentUser;
                                          if (user == null) {
                                            showDialog(
                                              context: context,
                                              builder: (_) => UnauthorizedDialog(
                                                onLogin: () {
                                                  final homeState = context
                                                      .findAncestorStateOfType<HomeScreenWrapperState>();
                                                  homeState?.openPage(HomePage.registration);
                                                },
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() => _showRecaptcha = true);
                                        }
                                      : null,
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: AppColors.neutreBlanc)
                                      : Text(S.of(context).check_fines, style: Theme.of(context).textTheme.whiteNormal),
                                ),
                              ),
                              if (_showRecaptcha)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                                    child: RecaptchaV2(
                                      apiKey: Env.recaptchaSiteKey,
                                      onVerifiedSuccessfully: (token) {
                                        setState(() => _showRecaptcha = false);
                                        carInfoCubit.checkFinesWithCaptcha(token);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  AppSpacers.verticalXXLarge,

                  BlocBuilder<CarInfoCubit, CarInfoState>(
                    builder: (context, state) {
                      if (state.status is CarInfoLoadedStatus && state.hasCheckedFines) {
                        final fines = (state.status as CarInfoLoadedStatus).fines;
                        if (fines.isEmpty) {
                          return Container(
                            width: double.infinity,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.neutreBlanc,
                              borderRadius: AppBorders.radius16,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AppSpacers.horizontalLarge,
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: const BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: AppColors.neutreBlanc, size: 26),
                                ),
                                AppSpacers.horizontalLarge,
                                Expanded(child: Text(S.of(context).no_fines, style: textTheme.noFinesText)),
                              ],
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  AppSpacers.verticalXLarge,

                  const AdBannerWidget(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
