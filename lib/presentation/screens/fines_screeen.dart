import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class FinesScreen extends StatefulWidget {
  final VoidCallback? onFineCheck;
  const FinesScreen({super.key, this.onFineCheck});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: AppColors.grey50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacers.verticalGigantic,
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: AppColors.blue700, borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                child: const Text(
                  'LOGO',
                  style: TextStyle(color: AppColors.neutreBlanc, fontSize: 56, fontWeight: FontWeight.bold),
                ),
              ),
              AppSpacers.verticalMassive,

              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue700,
                    shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                  ),
                  onPressed: () {
                    if (widget.onFineCheck != null) {
                      widget.onFineCheck!();
                    }
                  },
                  child: Text(S.of(context).check_fines, style: TextStyle(fontSize: 24, color: AppColors.neutreBlanc)),
                ),
              ),
              AppSpacers.verticalXXLarge,

              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.neutreBlanc,
                  borderRadius: AppBorders.radius16,
                  boxShadow: [
                    BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    AppSpacers.horizontalLarge,
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: AppColors.neutreBlanc, size: 26),
                    ),
                    AppSpacers.horizontalLarge,
                    Expanded(
                      child: Text(S.of(context).no_fines, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
