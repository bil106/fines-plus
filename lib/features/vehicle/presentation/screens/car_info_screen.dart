import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/unauthorized_dialog.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/features/vehicle/data/car_makes.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_photo_uploader.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/widgets/car_make_logo.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const CarInfoScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _CarInfoView(onBack: onBack);
  }
}

class _CarInfoView extends StatefulWidget {
  final VoidCallback? onBack;

  const _CarInfoView({this.onBack});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  CarCubit? carCubit;
  String? _selectedMake;
  String _photoUrl = '';
  bool _isUploadingPhoto = false;

  final _carReg = RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$');
  final _techReg = RegExp(r'^[A-Z]{3}\d{6}$');

  bool get isFormValid =>
      _carReg.hasMatch(_carNumberController.text) &&
      (_techPassportController.text.isEmpty || _techReg.hasMatch(_techPassportController.text));

  bool get hasCar => carCubit?.state.carNumber.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    carCubit = context.read<CarCubit>();

    _carNumberController.text = carCubit?.state.carNumber ?? '';
    _techPassportController.text = carCubit?.state.techPassport ?? '';

    _carNumberController.addListener(_onCarNumberChanged);
    _techPassportController.addListener(_onTechPassportChanged);

    // make/photoUrl aren't part of CarState — read the active car's current
    // values from the garage list this screen shares a provider with.
    final activeCarId = carCubit?.state.carId ?? '';
    final garageCars = context.read<GarageCubit>().state.cars;
    final activeCars = garageCars.where((c) => c.carId == activeCarId);
    if (activeCars.isNotEmpty) {
      final activeCar = activeCars.first;
      _selectedMake = activeCar.make.isNotEmpty ? activeCar.make : null;
      _photoUrl = activeCar.photoUrl;
    }
  }

  Future<void> _pickPhoto() async {
    final cubit = carCubit;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final carId = cubit?.state.carId ?? '';
    if (cubit == null || uid == null || carId.isEmpty) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await CarPhotoUploader().pickAndUpload(uid: uid, carId: carId);
      if (url != null) {
        await cubit.setPhotoUrl(url);
        if (mounted) setState(() => _photoUrl = url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${S.of(context).garage_action_error}: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _onMakeChanged(String? make) {
    setState(() => _selectedMake = make);
    if (make != null) carCubit?.setMake(make);
  }

  void _onCarNumberChanged() {
    final text = _carNumberController.text;

    if (mounted) setState(() {});

    carCubit?.changeCar(text);
    context.read<CarInfoCubit>().setCarNumber(text);
  }

  void _onTechPassportChanged() {
    final text = _techPassportController.text;

    if (mounted) setState(() {});

    carCubit?.setTechPassport(text);
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  void _handleUnauthorized() {
    showDialog(
      context: context,
      builder: (_) => UnauthorizedDialog(
        onLogin: () {
          Navigator.of(context).pop();
          context.router.push(RegistrationRoute());
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).delete_car_number),
        content: Text(S.of(context).delete_cars_confirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCars();
            },
            child: Text(S.of(context).delete, style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCars() async {
    final cubit = carCubit;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _handleUnauthorized();
      return;
    }

    context.read<StatisticsCubit>().clearStats();
    context.read<AnalyticsCubit>().stopListeningToCar();
    context.read<AnalyticsCubit>().clear();
    context.read<ExpensesCubit>().clearExpensesForCar();
    context.read<HistoryCubit>().clear();

    // Deletes the actual active car (its carId-keyed doc + subcollections)
    // via the same path the Garage screen uses — GarageCubit.deleteCar
    // also switches to a remaining car, or creates a fresh default one,
    // updating CarCubit's state that the fields below then pick up.
    final activeCarId = cubit?.state.carId ?? '';
    final garageCubit = context.read<GarageCubit>();
    final activeCars = garageCubit.state.cars.where((c) => c.carId == activeCarId);
    if (activeCars.isNotEmpty) {
      await garageCubit.deleteCar(activeCars.first);
    }

    _carNumberController.text = cubit?.state.carNumber ?? '';
    _techPassportController.text = cubit?.state.techPassport ?? '';

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).cars_deleted_success)));

    if (cubit == null || cubit.state.carId.isEmpty) {
      context.router.replaceAll([const HomeRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plateMarket = context.watch<AppConfig>().plateMarket;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.energyBlue50,

      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        leading: AppBackButton(onPressed: widget.onBack),
      ),

      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).addition_cars, style: textTheme.title),
                AppSpacers.verticalLarge,

                Card(
                  color: AppColors.neutreBlanc,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _isUploadingPhoto ? null : _pickPhoto,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.grey50,
                              backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                              child: _isUploadingPhoto
                                  ? const CircularProgressIndicator(strokeWidth: 2)
                                  : (_photoUrl.isEmpty
                                        ? const Icon(Icons.add_a_photo_outlined, color: AppColors.neutreGrey)
                                        : null),
                            ),
                          ),
                        ),
                        AppSpacers.verticalLarge,

                        Text(S.of(context).garage_make_label, style: textTheme.carNumber),
                        AppSpacers.verticalSmall,
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMake,
                          isExpanded: true,
                          hint: Text(S.of(context).garage_make_hint),
                          items: carMakes
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [CarMakeLogo(make: m, size: 20), AppSpacers.horizontalSmall, Text(m)],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _onMakeChanged,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.grey50,
                            border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                          ),
                        ),

                        AppSpacers.verticalLarge,

                        Text(S.of(context).car_number, style: textTheme.carNumber),
                        AppSpacers.verticalSmall,
                        TextField(
                          controller: _carNumberController,
                          style: textTheme.black28W400,
                          inputFormatters: [VehicleNumberFormatter(market: plateMarket)],
                          textCapitalization: TextCapitalization.characters,
                          maxLength: plateMarket.maxLength,
                          decoration: InputDecoration(
                            hintText: plateMarket.hint,
                            hintStyle: textTheme.hintText,
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.grey50,
                            border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                          ),
                        ),

                        // Tech passport is only used by the UA fines check.
                        if (context.watch<AppConfig>().finesCheckEnabled) ...[
                          AppSpacers.verticalLarge,

                          Text(S.of(context).reg_number, style: textTheme.carNumber),
                          AppSpacers.verticalSmall,
                          TextField(
                            controller: _techPassportController,
                            style: textTheme.black28W400,
                            inputFormatters: [TechPassportFormatter()],
                            maxLength: 9,
                            decoration: InputDecoration(
                              hintText: S.of(context).hint_tech_data_num,
                              hintStyle: textTheme.hintText,
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.grey50,
                              border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                AppSpacers.verticalLargeXL,

                Center(
                  child: TextButton(
                    onPressed: hasCar ? () => _showDeleteDialog(context) : null,
                    child: Text(
                      S.of(context).delete_car_number,
                      style: textTheme.bodyMedium?.copyWith(color: hasCar ? AppColors.red : AppColors.neutreGrey),
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
}
