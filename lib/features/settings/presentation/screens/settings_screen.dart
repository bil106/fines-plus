import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_page_app_bar.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
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
      photoPath: result['photoPath'] ?? '',
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

    // This device's cached car id and expense records belong to whoever was
    // signed in — leaving them behind would let a different account signed
    // into this device next inherit them before its own Firestore data
    // loads (see CarInfoLocalDataSource.ensureCarId's local-first check).
    final maintenanceCubit = context.read<MaintenanceCubit>();
    await context.read<CarCubit>().local.clearCarInfo();
    await maintenanceCubit.clearCachedRecords();

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
      appBar: AppPageAppBar(
        title: S.of(context).settings,
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
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

              const SizedBox(height: 18),

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
                          items: [
                            DropdownMenuItem(
                              value: const Locale('uk'),
                              child: Text(S.of(context).ukr),
                            ),
                            DropdownMenuItem(
                              value: const Locale('en'),
                              child: Text(S.of(context).english),
                            ),
                          ],
                          onChanged: (v) =>
                              context.read<SettingsCubit>().setLocale(v!),
                        ),
                        Divider(
                          thickness: 1,
                          height: 1,
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
                          height: 1,
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
                          height: 1,
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
                          height: 1,
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

              const SizedBox(height: 18),

              _buildSectionLabel(S.of(context).about_app_section),
              _buildFlatCard(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).app_version,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            _appVersion,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1, height: 1, color: context.brandTheme.divider),
                    _buildActionRow(
                      title: S.of(context).privacy_policy,
                      onTap: () => _openPrivacyPolicy(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: TextButton(
                  onPressed: () => _confirmLogout(context),
                  child: Text(
                    S.of(context).log_out,
                    style: TextStyle(
                      color: context.brandTheme.statusDanger,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.grey700,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: child,
    );
  }

  /// A car row with its actual photo (or make-logo fallback) instead of a
  /// generic icon, plus an edit/delete menu - both via garage_screen.dart's
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
        child: Stack(
          children: [
            Row(
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
                      Text(
                        car.carNumber,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CarMileageAndStatus(carId: car.carId),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.grey700),
              ],
            ),
            Positioned(
              top: -18,
              right: -12,
              child: PopupMenuButton<String>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_horiz, color: AppColors.grey700),
                onSelected: (action) => action == 'edit'
                    ? _editCar(context, car)
                    : confirmAndDeleteCar(context, car),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(S.of(context).edit)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      S.of(context).delete,
                      style: const TextStyle(color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
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
    final accent = color ?? AppColors.energyBlue;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: accent, size: 16),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: icon != null ? accent : null,
                  fontWeight: icon != null ? FontWeight.w700 : null,
                  fontSize: icon != null ? 13.5 : 14,
                ),
              ),
            ),
            if (icon == null) Icon(Icons.chevron_right, color: AppColors.grey700),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.neutreBlanc,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: DropdownButtonFormField<T>(
              value: value,
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                fillColor: AppColors.neutreBlanc,
                contentPadding: EdgeInsets.only(left: 12, top: 8, bottom: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              icon: const SizedBox.shrink(),
              isExpanded: true,
              selectedItemBuilder: (context) => items
                  .map(
                    (item) => Align(
                      alignment: Alignment.centerRight,
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        child: item.child,
                      ),
                    ),
                  )
                  .toList(),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
