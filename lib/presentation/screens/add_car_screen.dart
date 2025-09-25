// ignore_for_file: unused_element

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: AppColors.neutreBlanc, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: AppColors.neutreBlanc,
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacers.verticalXLarge,

                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 16, 
                      alignment: WrapAlignment.center,
                      children: [
                        _buildMenuSquare(
                          iconWidget: _buildSquareIcon(Icons.directions_car_rounded, S.of(context).auto, textTheme),
                          onTap: () {
                            if (widget.onOpenCarInfo != null) {
                              widget.onOpenCarInfo!.call();
                            } else {
                              context.router.push(CarInfoRoute(initialCarNumber: ''));
                            }
                          },
                        ),
                        _buildMenuSquare(
                          iconWidget: _buildSquareIcon(Icons.warning_amber_rounded, S.of(context).fines, textTheme),
                          onTap: () {
                            if (widget.onFineCheck != null) widget.onFineCheck!();
                          },
                        ),
                        _buildMenuSquare(
                          iconWidget: _buildSquareIcon(Icons.build, S.of(context).maintenance, textTheme),
                          onTap: () {
                            if (widget.onMaintenance != null) widget.onMaintenance!();
                          },
                        ),
                        _buildMenuSquare(
                          iconWidget: _buildSquareIcon(Icons.bar_chart, S.of(context).analitics, textTheme),
                          onTap: () async {
                            await analytics.logEvent(
                              name: 'analytics_button_clicked',
                              parameters: {'screen': 'AddCarScreen', 'button': 'Analytics'},
                            );

                            if (widget.onAnalytics != null) widget.onAnalytics!();
                          },
                        ),
                      ],
                    ),
                  ),

                  AppSpacers.verticalMaxMassive,
                  const AdBannerWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildSquareIcon(IconData icon, String text, TextTheme textTheme) {
  return Container(
    width: 165,
    height: 165,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(20),
      color: AppColors.grey50,
    ),
    child: Center(
      child: Column(
        children: [
          AppSpacers.verticalXLarge,
          Icon(icon, color: AppColors.blue700, size: 82),
          Text(text, style: textTheme.violationTitle),
        ],
      ),
    ),
  );
}

Widget _buildMenuSquare({IconData? icon, Color? iconColor, Widget? iconWidget, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        if (icon != null)
          Container(
            width: 165,
            height: 165,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.grey50),
            child: Icon(icon, color: iconColor ?? AppColors.grey50, size: 32),
          ),
        if (iconWidget != null) iconWidget,
        AppSpacers.verticalSmallMedium,
      ],
    ),
  );
}
