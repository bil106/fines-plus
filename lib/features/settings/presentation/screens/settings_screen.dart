// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _loadOldSettings();
  }

  Future<void> _loadOldSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      finesCheck = prefs.getBool("finesCheck") ?? true;
      reminders = prefs.getBool("reminders") ?? widget.remoteConfigService.isRemindersEnabled;
      pushNotifications = prefs.getBool("pushNotifications") ?? true;
    });
  }

  void _onSwitchChanged(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (key == "reminders") widget.scheduleCubit.enabled = value;

    setState(() {
      if (key == "finesCheck") finesCheck = value;
      if (key == "reminders") reminders = value;
      if (key == "pushNotifications") pushNotifications = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
        title: Text(
          S.of(context).settings,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Card(
                color: AppColors.neutreBlanc,
                shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    children: [
                      _buildSettingRow(
                        S.of(context).checking_fines,
                        finesCheck,
                        (v) => _onSwitchChanged("finesCheck", v),
                      ),
                      Divider(thickness: 2, color: AppColors.grey50),
                      _buildSettingRow(S.of(context).reminder, reminders, (v) => _onSwitchChanged("reminders", v)),
                      Divider(thickness: 2, color: AppColors.grey50),
                      _buildSettingRow(
                        S.of(context).push_notifications,
                        pushNotifications,
                        (v) => _onSwitchChanged("pushNotifications", v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

          BlocBuilder<SettingsCubit, SettingsState>(
  builder: (context, state) {
    return Card(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: [
            _buildDropdownRow<String>(
              context,
              icon: Icons.straighten,
              title: S.of(context).units,
              value: state.unit,
              items: const [
                DropdownMenuItem(value: 'km', child: Text('km')),
                DropdownMenuItem(value: 'mil', child: Text('mil')),
              ],
              onChanged: (v) => context.read<SettingsCubit>().setUnit(v!),
            ),
            Divider(thickness: 1.5, color: AppColors.grey50),
            _buildDropdownRow<String>(
              context,
              icon: Icons.currency_exchange,
              title: S.of(context).currency,
              value: state.currency,
              items: const [
                DropdownMenuItem(value: 'UAH', child: Text('UAH')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
              ],
              onChanged: (v) => context.read<SettingsCubit>().setCurrency(v!),
            ),
            Divider(thickness: 1.5, color: AppColors.grey50),
            _buildDropdownRow<Locale>(
              context,
              icon: Icons.language,
              title: S.of(context).language,
              value: state.locale,
              items: const [
                DropdownMenuItem(value: Locale('uk'), child: Text('Українська')),
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
              ],
              onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
            ),
          ],
        ),
      ),
    );
  },
)
 ])))); }
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

Widget _buildDropdownRow<T>(
    BuildContext context, {
    required IconData icon,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: AppColors.energyBlue),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(title, style: textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: DropdownButtonFormField<T>(
              value: value,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.energyBlue50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }


}