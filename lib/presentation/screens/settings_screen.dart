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
import 'package:shared_preferences/shared_preferences.dart';

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
  late bool finesCheck = true;
  late bool reminders = true;
  late bool pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      finesCheck = prefs.getBool("finesCheck") ?? true;
      reminders = prefs.getBool("reminders") ?? widget.remoteConfigService.isRemindersEnabled;
      pushNotifications = prefs.getBool("pushNotifications") ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onSwitchChanged(String key, bool value) {
    _saveSetting(key, value);
    if (key == "reminders") widget.scheduleCubit.enabled = value;
    setState(() {
      if (key == "finesCheck") finesCheck = value;
      if (key == "reminders") reminders = value;
      if (key == "pushNotifications") pushNotifications = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
                      _buildSettingRow(
                        S.of(context).checking_fines,
                        finesCheck,
                        (v) => _onSwitchChanged("finesCheck", v),
                      ),
                      Divider(thickness: 3, color: AppColors.grey50),
                      _buildSettingRow(S.of(context).reminder, reminders, (v) => _onSwitchChanged("reminders", v)),
                      Divider(thickness: 3, color: AppColors.grey50),
                      _buildSettingRow(
                        S.of(context).push_notifications,
                        pushNotifications,
                        (v) => _onSwitchChanged("pushNotifications", v),
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
    );
  }

  Widget _buildSettingRow(String title, bool value, ValueChanged<bool> onChanged) {
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
