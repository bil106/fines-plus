// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool finesCheck = true;
  bool reminders = true;
  bool pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
          appBar: AppBar(
          backgroundColor: AppColors.grey50,
          elevation: 0,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
          
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacers.verticalXLarge,
                Text(S.of(context).settings, style: textTheme.title),
                AppSpacers.verticalHuge,
                Card(
                  color: AppColors.neutreBlanc,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      children: [
                        AppSpacers.verticalLarge,
                        _buildSettingRow(
                          title: S.of(context).checking_fines,
                          value: finesCheck,
                          onChanged: (val) => setState(() => finesCheck = val),
                        ),
                        AppSpacers.verticalMediumLarge,
                        Divider(thickness: 3, color: AppColors.grey50),
                        AppSpacers.verticalMediumLarge,
                        _buildSettingRow(
                          title: S.of(context).reminder,
                          value: reminders,
                          onChanged: (val) => setState(() => reminders = val),
                        ),
                        AppSpacers.verticalMediumLarge,
                        Divider(thickness: 3, color: AppColors.grey50),
                        AppSpacers.verticalMediumLarge,
                        _buildSettingRow(
                          title: S.of(context).push_notifications,
                          value: pushNotifications,
                          onChanged: (val) => setState(() => pushNotifications = val),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildSettingRow({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: textTheme.titleLarge)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.neutreBlanc,
          activeTrackColor: AppColors.energyBlue,
        ),
      ],
    );
  }
}
