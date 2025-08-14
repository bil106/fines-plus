import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:design_system/colors/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class AddCarScreen extends StatefulWidget {
  final VoidCallback? onOpenCarInfo;
  const AddCarScreen({super.key, this.onOpenCarInfo});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: AppColors.grey50, statusBarIconBrightness: Brightness.dark),
      child: Container(
        color: AppColors.grey50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacers.verticalXLarge,
                  Text(
                    S.of(context).add_cars,
                    style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  AppSpacers.verticalHuge,
                  SizedBox(
                    height: screenHeight * 0.6,
                    width: double.infinity,
                    child: Card(
                      color: AppColors.neutreBlanc,
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_rounded, color: AppColors.blue700, size: 176),
                            AppSpacers.verticalHugeXL,
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.onOpenCarInfo != null) {
                                    widget.onOpenCarInfo!.call();
                                  } else {
                                    context.router.push(CarInfoRoute());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue700,
                                  shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Text(S.of(context).add_cars, style: TextStyle(fontSize: 24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
