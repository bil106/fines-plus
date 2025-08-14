import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: AppColors.grey50,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacers.verticalXLarge,
            Text(
              S.of(context).reminder,
              style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 36),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: AppColors.neutreBlanc, size: 140),
                    ),
                    AppSpacers.verticalMassive,
                    Text(S.of(context).no_fines, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
