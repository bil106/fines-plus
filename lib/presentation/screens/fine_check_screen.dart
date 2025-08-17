import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class FineCheckScreen extends StatefulWidget {
  final String carNumber;
  final VoidCallback? onFineCheck;
  const FineCheckScreen({super.key, this.onFineCheck, required this.carNumber});

  @override
  State<FineCheckScreen> createState() => _FineCheckScreenState();
}

class _FineCheckScreenState extends State<FineCheckScreen> {
  final _carNumberController = TextEditingController();
  final _techPassportController = TextEditingController();

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacers.verticalXLarge,
                Text(S.of(context).check_fine_title, style: textTheme.title),
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
                        AppSpacers.verticalMedium,
                        Text(
                          widget.carNumber,
                          style: textTheme.carNumber,
                        ),
                        AppSpacers.verticalMedium,
                        Text('340 грн', style: textTheme.totalFines),
                        AppSpacers.verticalMedium,
                        Text('10 листопада 2024', style: textTheme.fineDate),
                        AppSpacers.verticalMedium,
                        Container(height: 3, color: AppColors.neutreGrey100),
                        AppSpacers.verticalMedium,
                        Text('Перевищення швидкості', style: textTheme.violationTitle),
                      ],
                    ),
                  ),
                ),

                AppSpacers.verticalLargeXL,
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue700,
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                    ),
                    child: Text(S.of(context).pay, style: textTheme.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
