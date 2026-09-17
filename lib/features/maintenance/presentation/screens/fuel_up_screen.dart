import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_choice_chips.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_input_card.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/nearby_stations_sheet.dart';
import '../../../../../env/env.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class FuelUpScreen extends StatefulWidget {
  final VoidCallback? onBack;

  /// When true, renders just the form (no Scaffold/AppBar) for use inside
  /// [AppBottomSheet] - the dashboard's quick-add flow. Full-screen use
  /// (Maintenance tab, its FAB) leaves this false and is unaffected.
  final bool embedded;

  const FuelUpScreen({super.key, this.onBack, this.embedded = false});

  @override
  State<FuelUpScreen> createState() => FuelUpScreenState();
}

class FuelUpScreenState extends State<FuelUpScreen> {
  static const LatLng _fallbackPosition = LatLng(50.4501, 30.5234);
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final FocusNode _mileageFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _volumeFocusNode = FocusNode();

  FuelType selectedFuel = FuelType.Ai95;
  DateTime? selectedDate = DateTime.now();
  GasStation? _bestStation;
  double? _bestStationDistanceKm;
  bool _isLoadingBestStation = true;
  LatLng? _currentPosition;
  List<GasStation> _nearbyStations = [];

  late final GasStationService _gasService;

  @override
  void initState() {
    super.initState();
    _gasService = GasStationService(Env.mapApiKey);
    _initLocationAndStation();
    _loadLastPrice(selectedFuel);
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
    volumeController.dispose();
    mileageController.dispose();
    priceController.dispose();
    _mileageFocusNode.dispose();
    _priceFocusNode.dispose();
    _volumeFocusNode.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() => selectedDate = date);
    _mileageFocusNode.requestFocus();
  }

  void _onMileageChanged(String value) {
    if (value.length >= 6) _advanceFromMileage();
  }

  void _advanceFromMileage() {
    if (priceController.text.isNotEmpty) {
      _volumeFocusNode.requestFocus();
    } else {
      _priceFocusNode.requestFocus();
    }
  }

  Future<void> _loadLastPrice(FuelType fuel) async {
    final cached = await FuelPriceCache.getPrice(fuel.name);
    if (cached != null) {
      priceController.text = cached.round().toString();
    } else {
      priceController.clear();
    }
  }

  void _onPriceChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      FuelPriceCache.savePrice(selectedFuel.name, parsed);
    }
  }

  Future<void> _initLocationAndStation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print(
            'FuelUpScreen: geolocation unavailable, using fallback position',
          );
        }
        await _loadBestStationFrom(_fallbackPosition);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
      await _loadBestStationFrom(LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (kDebugMode) print("Error getting position: $e");
      await _loadBestStationFrom(_fallbackPosition);
    }
  }

  Future<void> _loadBestStationFrom(LatLng current) async {
    _currentPosition = current;
    final stations = await _fetchNearbyGasStations(current);
    if (!mounted) return;

    final bestStation = _pickBestStation(stations, current);
    final distanceKm = bestStation == null
        ? null
        : Geolocator.distanceBetween(
                current.latitude,
                current.longitude,
                bestStation.lat,
                bestStation.lng,
              ) /
              1000;
    setState(() {
      _nearbyStations = stations;
      _bestStation = bestStation;
      _bestStationDistanceKm = distanceKm;
      _isLoadingBestStation = false;
    });
  }

  Future<List<GasStation>> _fetchNearbyGasStations(LatLng current) async {
    try {
      return await _gasService.fetchNearbyGasStations(current);
    } catch (e) {
      if (kDebugMode) print("Error fetching stations: $e");
      return [];
    }
  }

  /// Prefers well-rated stations, but a 4.5+ bar routinely excluded every
  /// station in the area — never come back empty just because none happen
  /// to clear a high bar; fall back to the nearest one instead.
  GasStation? _pickBestStation(List<GasStation> stations, LatLng current) {
    if (stations.isEmpty) return null;

    double distanceTo(GasStation s) => Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      s.lat,
      s.lng,
    );

    try {
      final wellRated = stations.where((s) => s.rating >= 4.0).toList();
      final candidates = wellRated.isNotEmpty ? wellRated : stations;

      candidates.sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));

      return candidates.first;
    } catch (e) {
      if (kDebugMode) print("Error fetching stations: $e");
      return null;
    }
  }

  /// Validates and saves the current form, then closes/reports as
  /// appropriate for how this screen was presented. Shared by the AppBar
  /// check action (full-screen mode) and the pinned Save button in
  /// [AppBottomSheet] (embedded mode).
  void save() {
    if (selectedDate == null ||
        volumeController.text.isEmpty ||
        mileageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.blue700,
          content: Text(S.of(context).fill_date),
        ),
      );
      return;
    }

    final volume = double.tryParse(volumeController.text) ?? 0;
    final mileage = int.tryParse(mileageController.text) ?? 0;
    final pricePerLiter = double.tryParse(priceController.text) ?? 0;
    final totalCost = volume * pricePerLiter;

    final record = FuelRecord(
      fuelType: selectedFuel.name,
      volume: volume,
      cost: totalCost,
      date: selectedDate!,
      mileage: mileage,
      currency: context.read<SettingsCubit>().state.currency,
    );

    // This screen is reached as a pushed route (Maintenance FAB), as a
    // static PageView page (main "Заправка" tile), and embedded in a
    // bottom sheet (dashboard quick-add) - none of those reliably have a
    // caller awaiting a popped value, so it must save the record itself.
    context.read<MaintenanceCubit>().addFuelRecord(record);

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();

    if (widget.embedded) {
      return _buildForm(textTheme, settingsCubit);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.neutreBlanc,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          elevation: 0,
          leading: AppBackButton(onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.blue, size: 50),
              onPressed: save,
            ),
          ],
        ),
        body: _buildForm(textTheme, settingsCubit),
      ),
    );
  }

  Widget _buildForm(TextTheme textTheme, SettingsCubit settingsCubit) {
    return SingleChildScrollView(
      padding: widget.embedded ? EdgeInsets.zero : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.embedded)
            Text(S.of(context).fuel_up, style: textTheme.title),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (_currentPosition == null || _nearbyStations.isEmpty)
                      ? null
                      : () {
                          showNearbyStationsSheet(
                            context,
                            currentPosition: _currentPosition!,
                            stations: _nearbyStations,
                            onSelected: (station) {
                              context.router.push(
                                FuelMapRoute(
                                  focusPosition: LatLng(
                                    station.lat,
                                    station.lng,
                                  ),
                                  focusName: station.name,
                                ),
                              );
                            },
                          );
                        },
                  child: Card(
                    color: AppColors.neutreBlanc,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _isLoadingBestStation
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.blueAccent,
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _bestStation == null
                                            ? S.of(context).no_nearby_station
                                            : _bestStation!.vicinity.isEmpty
                                            ? _bestStation!.name
                                            : '${_bestStation!.name} — ${_bestStation!.vicinity}',
                                        style: _bestStation == null
                                            ? textTheme.black14bold.copyWith(
                                                fontWeight: FontWeight.normal,
                                              )
                                            : textTheme.black14bold,
                                        maxLines: _bestStation == null ? 2 : 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_bestStation != null &&
                                          _bestStationDistanceKm != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          S
                                              .of(context)
                                              .best_price_nearby_distance(
                                                _bestStationDistanceKm!
                                                    .toStringAsFixed(1),
                                              ),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppColors.grey700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (_bestStation != null)
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.grey700,
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          AppSpacers.verticalXSmall,

          Row(
            children: [
              Expanded(
                child: DatePickerCard(
                  selectedDate: selectedDate,
                  onDateSelected: _onDateSelected,
                ),
              ),
              AppSpacers.horizontalLarge,
              Expanded(
                child: MileageCard(
                  textTheme: textTheme,
                  controller: mileageController,
                  focusNode: _mileageFocusNode,
                  onChanged: _onMileageChanged,
                  onSubmitted: (_) => _advanceFromMileage(),
                ),
              ),
            ],
          ),

          AppSpacers.verticalXSmall,
          Text(S.of(context).fuel_type, style: textTheme.subtitleText),
          AppSpacers.verticalXSmall,

          FuelChoiceChips(
            fuels: const [
              FuelType.Ai95,
              FuelType.Ai92,
              FuelType.DIESEl,
              FuelType.LPG,
            ],
            selectedFuel: selectedFuel,
            onSelected: (fuel) {
              setState(() {
                selectedFuel = fuel;
                _loadLastPrice(fuel);
              });
            },
          ),

          AppSpacers.verticalMediumLarge,
          FuelPriceVolumeSumRow(
            volumeController: volumeController,
            priceController: priceController,
            onPriceChanged: _onPriceChanged,
            priceFocusNode: _priceFocusNode,
            volumeFocusNode: _volumeFocusNode,
          ),

          AppSpacers.verticalXLarge,
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
