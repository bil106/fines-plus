import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
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
    // final screenHeight = MediaQuery.of(context).size.height;

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
                Text(
                  S.of(context).check_fine_title,
                  style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 36),
                ),
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
                            style: TextStyle(fontSize: 28, color: AppColors.black87, fontWeight: FontWeight.w500),
                          ),
                          AppSpacers.verticalMedium,
                          const Text(
                            '340 грн',
                            style: TextStyle(fontSize: 58, color: AppColors.black87, fontWeight: FontWeight.w600),
                          ),
                          AppSpacers.verticalMedium,
                          const Text(
                            '10 листопада 2024',
                            style: TextStyle(fontSize: 28, color: AppColors.black87, fontWeight: FontWeight.w500),
                          ),
                          AppSpacers.verticalMedium,
                          Container(height: 3, color: AppColors.neutreGrey100),
                          AppSpacers.verticalMedium,
                          const Text(
                            'Перевищення швидкості',
                            style: TextStyle(fontSize: 24, color: AppColors.black87, fontWeight: FontWeight.w500),
                          ),
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
                    child: Text(S.of(context).pay, style: TextStyle(fontSize: 24)),
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
