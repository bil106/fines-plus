// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/core/extensions/safe_prefs.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    if (!mounted) return;
    setState(() {
      finesCheck = prefs.getBoolSafe("finesCheck", defaultValue: true);
      reminders = prefs.getBoolSafe("reminders", defaultValue: widget.remoteConfigService.isRemindersEnabled);
      pushNotifications = prefs.getBoolSafe("pushNotifications", defaultValue: true);
    });
  }

  void _onSwitchChanged(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (key == "reminders") widget.scheduleCubit.enabled = value;
if (!mounted) return;
    setState(() {
      if (key == "finesCheck") finesCheck = value;
      if (key == "reminders") reminders = value;
      if (key == "pushNotifications") pushNotifications = value;
    });
  }

  void _changeCarInfo(BuildContext context) {
    context.findAncestorStateOfType<HomeScreenWrapperState>()?.openPage(HomePage.carInfo);
  }

  void _openGarage(BuildContext context) {
    context.findAncestorStateOfType<HomeScreenWrapperState>()?.openPage(HomePage.garage);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).delete_account),
        content: Text(S.of(context).delete_account_confirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.of(context).delete_account, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final registrationCubit = context.read<RegistrationCubit>();
    await registrationCubit.deleteAccount();

    if (!context.mounted) return;
    final state = registrationCubit.state;
    if (state.isDeleted) {
      try { await GoogleSignIn.instance.signOut(); } catch (_) {}
      context.router.root.replaceAll([RegistrationRoute()]);
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).log_out),
        content: Text(S.of(context).log_out_confirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(S.of(context).cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(S.of(context).log_out)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    context.router.root.replaceAll([RegistrationRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
        title: Text(S.of(context).settings, style: Theme.of(context).textTheme.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.neutreBlanc,
                shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  child: Column(
                    children: [
                      _buildSettingRow(
                        S.of(context).checking_fines,
                        finesCheck,
                        (v) => _onSwitchChanged("finesCheck", v),
                      ),
                      Divider(thickness: 1, color: AppColors.energyBlue50),
                      _buildSettingRow(S.of(context).reminder, reminders, (v) => _onSwitchChanged("reminders", v)),
                      Divider(thickness: 1, color: AppColors.energyBlue50),
                      _buildSettingRow(
                        S.of(context).push_notifications,
                        pushNotifications,
                        (v) => _onSwitchChanged("pushNotifications", v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return Card(
                    color: AppColors.neutreBlanc,
                    shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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

                          Divider(thickness: 1, color: AppColors.energyBlue50),

                          _buildDropdownRow<String>(
                            context,
                            icon: Icons.local_gas_station,
                            title: S.of(context).fuel_consumption,
                            value: state.fuelConsumptionUnit,
                            items: const [
                              DropdownMenuItem(value: 'l/100km', child: Text('l/100km')),
                              DropdownMenuItem(value: 'mpg', child: Text('mpg')),
                            ],
                            onChanged: (v) => context.read<SettingsCubit>().setFuelConsumptionUnit(v!),
                          ),

                          Divider(thickness: 1, color: AppColors.energyBlue50),
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
                          Divider(thickness: 1, color: AppColors.energyBlue50),
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
              ),

              const SizedBox(height: 10),

              Card(
                color: AppColors.neutreBlanc,
                shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  child: Column(
                    children: [
                      _buildActionRow(
                        icon: Icons.garage_outlined,
                        title: S.of(context).my_garage,
                        onTap: () => _openGarage(context),
                      ),
                      Divider(thickness: 1, color: AppColors.energyBlue50),
                      _buildActionRow(
                        icon: Icons.directions_car_outlined,
                        title: S.of(context).change_car_info,
                        onTap: () => _changeCarInfo(context),
                      ),
                      Divider(thickness: 1, color: AppColors.energyBlue50),
                      _buildActionRow(
                        icon: Icons.logout,
                        title: S.of(context).log_out,
                        color: AppColors.purpleRed,
                        onTap: () => _confirmLogout(context),
                      ),
                      Divider(thickness: 1, color: AppColors.energyBlue50),
                      BlocConsumer<RegistrationCubit, RegistrationState>(
                        listenWhen: (prev, curr) => curr.isLoading != prev.isLoading,
                        listener: (_, __) {},
                        builder: (context, regState) {
                          if (regState.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildActionRow(
                            icon: Icons.delete_forever,
                            title: S.of(context).delete_account,
                            color: Colors.red.shade800,
                            onTap: () => _confirmDeleteAccount(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.energyBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: textTheme.bodyLarge?.copyWith(color: color))),
            Icon(Icons.chevron_right, color: AppColors.grey700, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, bool value, ValueChanged<bool> onChanged) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: textTheme.bodyLarge)),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.neutreBlanc,
              activeTrackColor: AppColors.energyBlue,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: AppColors.energyBlue, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(title, style: textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: DropdownButtonFormField<T>(
              value: value,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.energyBlue50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
