import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_page_app_bar.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_state.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/garage_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool pushNotifications = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadOldSettings();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final config = context.read<AppConfig>();
    try {
      await launchUrl(
        Uri.parse(config.privacyPolicyUrl ?? Env.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  // Car add/edit and Firestore persistence are exactly what "Мій гараж"
  // (garage_screen.dart) already used - GarageCubit + this same
  // showCarFormSheet - only reused here instead of duplicated, so that
  // screen's entry point could be dropped from Settings without losing it.
  Future<void> _addCar(BuildContext context) async {
    final result = await showCarFormSheet(context);
    if (result == null || !context.mounted) return;
    await context.read<GarageCubit>().addCar(
      carNumber: result['carNumber'] ?? '',
      techPassport: result['techPassport'] ?? '',
      make: result['make'] ?? '',
    );
  }

  Future<void> _editCar(BuildContext context, CarInfoModel car) async {
    final result = await showCarFormSheet(context, existing: car);
    if (result == null || !context.mounted) return;
    await context.read<GarageCubit>().updateCar(
      car,
      carNumber: result['carNumber'],
      techPassport: result['techPassport'],
      make: result['make'],
      photoUrl: result['photoUrl'],
    );
  }

  Future<void> _loadOldSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      pushNotifications = prefs.getBool("pushNotifications") ?? true;
    });
  }

  void _onSwitchChanged(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (!mounted) return;
    setState(() {
      if (key == "pushNotifications") pushNotifications = value;
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).log_out),
        content: Text(S.of(context).log_out_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.of(context).log_out),
          ),
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
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppPageAppBar(title: S.of(context).settings, onBack: widget.onBack),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(S.of(context).vehicles_section),
              // Car add/edit/switch logic and Firestore persistence are
              // untouched (GarageCubit + showCarFormSheet from garage_screen
              // - same as before this restyle) - only this card's look
              // changed to match the flat mockup.
              BlocBuilder<GarageCubit, GarageState>(
                builder: (context, garageState) {
                  // A fresh account gets an auto-created plate-less car so
                  // there's always an active carId (see CarCubit.ensureCarId)
                  // - it's an internal bookkeeping placeholder, not something
                  // the user typed in, so it doesn't belong in this list.
                  final cars = garageState.cars
                      .where((c) => c.carNumber.isNotEmpty)
                      .toList();
                  return _buildFlatCard(
                    child: Column(
                      children: [
                        for (final car in cars) ...[
                          _buildCarRow(
                            context,
                            car,
                            isActive: car.carId == garageState.activeCarId,
                          ),
                          Divider(
                            thickness: 1,
                            color: context.brandTheme.divider,
                          ),
                        ],
                        _buildActionRow(
                          icon: Icons.add,
                          title: S.of(context).add_car,
                          onTap: () => _addCar(context),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              _buildSectionLabel(S.of(context).general_section),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return _buildFlatCard(
                    child: Column(
                      children: [
                        _buildDropdownRow<Locale>(
                          context,
                          title: S.of(context).language,
                          value: state.locale,
                          items: const [
                            DropdownMenuItem(
                              value: Locale('uk'),
                              child: Text('Українська'),
                            ),
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                          ],
                          onChanged: (v) =>
                              context.read<SettingsCubit>().setLocale(v!),
                        ),
                        Divider(
                          thickness: 1,
                          color: context.brandTheme.divider,
                        ),
                        _buildDropdownRow<String>(
                          context,
                          title: S.of(context).currency,
                          value: state.currency,
                          items: const [
                            DropdownMenuItem(value: 'UAH', child: Text('UAH')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                          ],
                          onChanged: (v) =>
                              context.read<SettingsCubit>().setCurrency(v!),
                        ),
                        Divider(
                          thickness: 1,
                          color: context.brandTheme.divider,
                        ),
                        _buildDropdownRow<String>(
                          context,
                          title: S.of(context).units,
                          value: state.unit,
                          items: const [
                            DropdownMenuItem(value: 'km', child: Text('km')),
                            DropdownMenuItem(value: 'mil', child: Text('mil')),
                          ],
                          onChanged: (v) =>
                              context.read<SettingsCubit>().setUnit(v!),
                        ),
                        Divider(
                          thickness: 1,
                          color: context.brandTheme.divider,
                        ),
                        _buildDropdownRow<String>(
                          context,
                          title: S.of(context).fuel_consumption,
                          value: state.fuelConsumptionUnit,
                          items: const [
                            DropdownMenuItem(
                              value: 'l/100km',
                              child: Text('l/100km'),
                            ),
                            DropdownMenuItem(value: 'mpg', child: Text('mpg')),
                          ],
                          onChanged: (v) => context
                              .read<SettingsCubit>()
                              .setFuelConsumptionUnit(v!),
                        ),
                        Divider(
                          thickness: 1,
                          color: context.brandTheme.divider,
                        ),
                        _buildSettingRow(
                          S.of(context).reminder_notifications,
                          pushNotifications,
                          (v) => _onSwitchChanged("pushNotifications", v),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              _buildSectionLabel(S.of(context).about_app_section),
              _buildFlatCard(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).app_version,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            _appVersion,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1, color: context.brandTheme.divider),
                    _buildActionRow(
                      title: S.of(context).privacy_policy,
                      onTap: () => _openPrivacyPolicy(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: TextButton(
                  onPressed: () => _confirmLogout(context),
                  child: Text(
                    S.of(context).log_out,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.grey700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Flat, borderless-shadow card matching the rest of the redesigned
  /// dashboard (see AppBrandTheme's doc comment) - white, distinct from the
  /// page's own warm-neutral background (unlike the previous elevated Card
  /// look, which shared the page color and only showed a shadow).
  Widget _buildFlatCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radius22,
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: child,
    );
  }

  /// A car row with its actual photo (or make-logo fallback) instead of a
  /// generic icon, plus a delete button - both via garage_screen.dart's
  /// shared Thumbnail/confirmAndDeleteCar, same as "Мій гараж" used to have.
  Widget _buildCarRow(
    BuildContext context,
    CarInfoModel car, {
    required bool isActive,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => _editCar(context, car),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Thumbnail(
              photoUrl: car.photoUrl,
              make: car.make,
              isActive: isActive,
              size: 72,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(car.carNumber, style: textTheme.titleLarge),
                  CarMileageAndStatus(carId: car.carId),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: () => confirmAndDeleteCar(context, car),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey700),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color ?? AppColors.energyBlue),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(color: color),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey700),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
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
            child: Text(
              title,
              style: textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
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
                fillColor: context.brandTheme.surfaceBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.brandTheme.surfaceBorder,
                  ),
                ),
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
