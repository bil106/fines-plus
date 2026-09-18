import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/features/maintenance/domain/nearby_service_ranking.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/cost_input_card.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/nearby_services_sheet.dart';
import '../../../../../env/env.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_map_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class CarWashScreen extends StatefulWidget {
  final VoidCallback? onBack;

  /// When true, renders just the form (no Scaffold/AppBar) for use inside
  /// [AppBottomSheet] - the dashboard's quick-add flow. Full-screen use
  /// (Maintenance tab, its FAB) leaves this false and is unaffected.
  final bool embedded;

  const CarWashScreen({super.key, this.onBack, this.embedded = false});

  @override
  State<CarWashScreen> createState() => CarWashScreenState();
}

class CarWashScreenState extends State<CarWashScreen> {
  static const LatLng _fallbackPosition = LatLng(50.4501, 30.5234);
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode _mileageFocusNode = FocusNode();

  DateTime? selectedDate = DateTime.now();
  LatLng? _currentPosition;
  List<Map<String, dynamic>> _nearbyWashes = [];
  Map<String, dynamic>? _bestCarWash;
  bool _isLoadingBestCarWash = true;
  bool _locationUnavailable = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndCarWash();
    _prefillLastMileage();
  }

  void _prefillLastMileage() {
    final lastMileage = context.read<MaintenanceCubit>().getLastKnownMileage();
    if (lastMileage != null) {
      mileageController.text = lastMileage.toString();
    }
  }

  @override
  void dispose() {
    mileageController.dispose();
    costController.dispose();
    _mileageFocusNode.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() => selectedDate = date);
    _mileageFocusNode.requestFocus();
  }

  Future<void> _initLocationAndCarWash() async {
    setState(() {
      _isLoadingBestCarWash = true;
      _locationUnavailable = false;
      _loadFailed = false;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('CarWashScreen: geolocation unavailable, using fallback position');
        if (mounted) setState(() => _locationUnavailable = true);
        await _loadNearbyWashesFrom(_fallbackPosition);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 5));
      await _loadNearbyWashesFrom(LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (kDebugMode) {
        print("Error getting car wash: $e");
      }
      await _loadNearbyWashesFrom(_fallbackPosition);
    }
  }

  Future<void> _loadNearbyWashesFrom(LatLng current) async {
    _currentPosition = current;
    try {
      final washes = await fetchNearbyCarWashes(current, Env.mapApiKey);
      if (!mounted) return;
      setState(() {
        _nearbyWashes = rankNearbyServices(washes, current);
        _bestCarWash = _nearbyWashes.isEmpty ? null : _nearbyWashes.first;
        _isLoadingBestCarWash = false;
      });
    } catch (e) {
      if (kDebugMode) print("Error fetching car washes: $e");
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _isLoadingBestCarWash = false;
      });
    }
  }

  Future<void> _openWashes() async {
    if (_currentPosition == null || _nearbyWashes.isEmpty) return;
    FocusScope.of(context).unfocus();
    final wash = await showNearbyServicesSheet(
      context,
      currentPosition: _currentPosition!,
      stations: _nearbyWashes,
      title: S.of(context).car_wash_nearby,
      icon: Icons.local_car_wash,
    );
    if (wash == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CarWashMapScreen(
          focusPosition: LatLng(
            (wash['lat'] as num).toDouble(),
            (wash['lng'] as num).toDouble(),
          ),
          focusName: wash['name'] as String,
        ),
      ),
    );
  }

  Widget _buildStationCard() {
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final title = _locationUnavailable
        ? s.car_wash_location_unavailable
        : _loadFailed
        ? s.car_wash_load_failed
        : _bestCarWash == null
        ? s.car_wash_no_nearby
        : [_bestCarWash!['name'], _bestCarWash!['vicinity']]
              .where((value) => value != null && value.toString().isNotEmpty)
              .join(' — ');
    return Material(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.brandTheme.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isLoadingBestCarWash
            ? null
            : _bestCarWash == null
            ? _initLocationAndCarWash
            : _openWashes,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _isLoadingBestCarWash
              ? const Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.local_car_wash,
                      color: AppColors.blueAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _bestCarWash == null
                                ? s.service_retry
                                : ((_bestCarWash!['rating'] as num?) ?? 0) > 0
                                ? s.car_wash_best_rating_distance(
                                    serviceDistanceKm(
                                      _bestCarWash!,
                                      _currentPosition!,
                                    ).toStringAsFixed(1),
                                  )
                                : s.distance_km_short(
                                    serviceDistanceKm(
                                      _bestCarWash!,
                                      _currentPosition!,
                                    ).toStringAsFixed(1),
                                  ),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _bestCarWash == null ? Icons.refresh : Icons.chevron_right,
                      color: AppColors.grey700,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (widget.embedded) {
      return _buildForm(textTheme);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.grey50, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: context.brandTheme.surfaceBg,
        appBar: AppBar(
          backgroundColor: context.brandTheme.surfaceBg,
          elevation: 0,
          leading: AppBackButton(onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.blue700, size: 50),
              onPressed: save,
            ),
          ],
        ),
        body: _buildForm(textTheme),
      ),
    );
  }

  Widget _buildForm(TextTheme textTheme) {
    return SingleChildScrollView(
      padding: widget.embedded ? EdgeInsets.zero : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.embedded)
            Text(S.of(context).car_wash, style: textTheme.title),
          if (!widget.embedded) const SizedBox(height: 16),

          _buildStationCard(),
          AppSpacers.verticalMedium,

          Row(
            children: [
              Expanded(
                child: DatePickerCard(selectedDate: selectedDate, onDateSelected: _onDateSelected),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MileageCard(
                  textTheme: textTheme,
                  controller: mileageController,
                  focusNode: _mileageFocusNode,
                ),
              ),
            ],
          ),

          AppSpacers.verticalMedium,
          Text(S.of(context).price, style: textTheme.subtitleText),
          AppSpacers.verticalMedium,
          CostInputCard(controller: costController),

          AppSpacers.verticalXLarge,
          const AdBannerWidget(),
        ],
      ),
    );
  }

  /// Validates and saves the current form, then closes/reports as
  /// appropriate for how this screen was presented. Shared by the AppBar
  /// check action (full-screen mode) and the pinned Save button in
  /// [AppBottomSheet] (embedded mode).
  void save() {
    if (selectedDate == null || mileageController.text.isEmpty || costController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(backgroundColor: AppColors.blue700, content: Text(S.of(context).fill_date)));
      return;
    }

    final mileage = int.tryParse(mileageController.text) ?? 0;
    final cost = double.tryParse(costController.text) ?? 0;

    final record = CarWashRecord(
      date: selectedDate!,
      mileage: mileage,
      amount: cost,
      ownerId: 'default_user',
    );

    // This screen is reached as a pushed route (Maintenance FAB), as a
    // static PageView page (main "Автомийка" tile), and embedded in a
    // bottom sheet (dashboard quick-add) - none of those reliably have a
    // caller awaiting a popped value, so it must save the record itself.
    context.read<MaintenanceCubit>().addCarWashRecord(record);

    if (widget.embedded) {
      Navigator.of(context).pop(record);
    } else if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.router.canPop()) {
      context.router.pop(record);
    } else {
      Navigator.of(context).maybePop(record);
    }
  }
}
