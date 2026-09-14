// ignore_for_file: unnecessary_import

import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AddCarScreen extends StatefulWidget {
  final VoidCallback? onOpenCarInfo;
  final VoidCallback? onFineCheck;
  final VoidCallback? onMaintenance;
  final VoidCallback? onAnalytics;

  const AddCarScreen({super.key, this.onOpenCarInfo, this.onFineCheck, this.onMaintenance, this.onAnalytics});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = _auth.currentUser;
    final bool hasCar = context.watch<CarCubit>().state.carId.isNotEmpty;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.energyBlue50,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: user != null ? _firestore.collection('users').doc(user.uid).snapshots() : const Stream.empty(),
            builder: (context, snapshot) {
              bool isSubscribed = kDebugMode;

              if (!kDebugMode && snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                isSubscribed = data['isSubscribed'] ?? false;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacers.verticalXLarge,

                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          AbsorbPointer(
                            absorbing: !hasCar && !kDebugMode,
                            child: _buildMenuSquare(
                              iconWidget: buildGradientSquare(
                                'assets/images/maintenance_bg.png',
                                S.of(context).maintenance,
                                textTheme,
                              ),
                              onTap: widget.onMaintenance,
                            ),
                          ),
                          AbsorbPointer(
                            absorbing: !hasCar && !kDebugMode,
                            child: _buildMenuSquare(
                              iconWidget: buildGradientSquare(
                                'assets/images/analytics_bg.png',
                                S.of(context).analitics,
                                textTheme,
                              ),
                              onTap: widget.onAnalytics,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacers.verticalMaxMassive,

                    if (!isSubscribed) const AdBannerWidget(),

                    AppSpacers.verticalMaxMassive,

                    if (!isSubscribed)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 20),
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                                wrapperState?.openPage(HomePage.subscription);
                              },
                              child: Text(
                                S.of(context).subscription,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.neutreBlanc,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildMenuSquare({Widget? iconWidget, required VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(children: [if (iconWidget != null) iconWidget, AppSpacers.verticalSmallMedium]),
  );
}

Widget buildGradientSquare(String assetImage, String text, TextTheme textTheme) {
  return Container(
    width: 165,
    height: 165,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      image: DecorationImage(image: AssetImage(assetImage), fit: BoxFit.cover),
      boxShadow: [BoxShadow(color: AppColors.blueGrey08, blurRadius: 10, offset: const Offset(0, 6))],
    ),
    child: Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.blueGrey25),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.neutreBlanc,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    ),
  );
}
