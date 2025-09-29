// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_cubit/cubit/schedule/schedule_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final RemoteConfigService remoteConfigService;
  final ScheduleCubit scheduleCubit;
  final PurchaseCubit purchaseCubit;

  const SettingsScreen({
    super.key,
    this.onBack,
    required this.remoteConfigService,
    required this.scheduleCubit,
    required this.purchaseCubit,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool finesCheck;
  late bool reminders;
  late bool pushNotifications;
  @override
  void initState() {
    super.initState();

    finesCheck = true;
    reminders = widget.remoteConfigService.isRemindersEnabled;
    pushNotifications = true;
  }

  void _logSwitchChange(String name, bool value) {
    debugPrint("👉 $name switched to $value");
  }

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
                          onChanged: (val) {
                            setState(() => finesCheck = val);
                            _logSwitchChange("checking_fines", val);
                            debugPrint(
                              "👉 RemoteConfig.isRemindersEnabled = ${context.read<RemoteConfigService>().isRemindersEnabled}",
                            );
                          },
                        ),

                        AppSpacers.verticalMediumLarge,
                        Divider(thickness: 3, color: AppColors.grey50),
                        AppSpacers.verticalMediumLarge,

                        _buildSettingRow(
                          title: S.of(context).reminder,
                          value: reminders,
                          onChanged: (val) {
                            setState(() => reminders = val);
                            widget.scheduleCubit.enabled = val;
                            _logSwitchChange("reminder", val);
                            debugPrint("👉 scheduleCubit.enabled = ${widget.scheduleCubit.enabled}");
                          },
                        ),

                        AppSpacers.verticalMediumLarge,
                        Divider(thickness: 3, color: AppColors.grey50),
                        AppSpacers.verticalMediumLarge,

                        _buildSettingRow(
                          title: S.of(context).push_notifications,
                          value: pushNotifications,
                          onChanged: (val) {
                            setState(() => pushNotifications = val);
                            _logSwitchChange("push_notifications", val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacers.verticalMassive,
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
