import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
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
  final TextEditingController sumController = TextEditingController();
  // Which of volume/sum the user typed last - the other one is derived from it.
  bool _sumIsSource = false;
  final FocusNode _mileageFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _volumeFocusNode = FocusNode();

  FuelType selectedFuel = FuelType.Ai95;
  bool get _isElectric => selectedFuel.isElectric;
  bool _fullTank = false;
  final TextEditingController tankController = TextEditingController();
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
    _loadTankVolume();
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
    sumController.dispose();
    tankController.dispose();
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
      priceController.text = _formatNumber(cached);
    } else {
      priceController.clear();
    }
    _recalculate();
  }

  String get _carNumber => context.read<CarCubit>().state.carNumber;

  Future<void> _loadTankVolume() async {
    final saved = await FuelTankCache.getVolume(_carNumber, electric: _isElectric);
    if (saved == null || !mounted) return;
    tankController.text = _formatLiters(saved);
    if (_fullTank) _onFullTankChanged(true);
  }

  /// Switching between fuel and electricity changes the unit (liters / kWh),
  /// so the amount fields, the remembered tank / battery capacity and the
  /// nearby stations (gas stations / chargers) are all reset for the new kind.
  void _onFuelSelected(FuelType fuel) {
    final electricChanged = fuel.isElectric != selectedFuel.isElectric;
    setState(() {
      selectedFuel = fuel;
      if (electricChanged) {
        _isLoadingBestStation = true;
        tankController.clear();
        volumeController.clear();
        sumController.clear();
      }
    });
    _loadLastPrice(fuel);
    if (electricChanged) {
      _loadTankVolume();
      _loadBestStationFrom(_currentPosition ?? _fallbackPosition);
    }
  }

  String _formatLiters(double liters) => liters == liters.roundToDouble() ? liters.toInt().toString() : liters.toString();

  /// A full-tank fill-up is assumed to add the car's whole tank; the volume
  /// stays editable for when the tank wasn't empty.
  void _onFullTankChanged(bool value) {
    setState(() => _fullTank = value);
    if (value && tankController.text.isNotEmpty) {
      volumeController.text = tankController.text;
      _onVolumeChanged(tankController.text);
    }
  }

  void _onTankVolumeChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    FuelTankCache.saveVolume(_carNumber, parsed, electric: _isElectric);
    if (_fullTank) {
      volumeController.text = value;
      _onVolumeChanged(value);
    }
  }

  void _onPriceChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      FuelPriceCache.savePrice(selectedFuel.name, parsed);
    }
    _recalculate();
  }

  void _onVolumeChanged(String _) {
    _sumIsSource = false;
    _recalculate();
  }

  void _onSumChanged(String _) {
    _sumIsSource = true;
    _recalculate();
  }

  /// Keeps volume, price and sum consistent: whichever of volume/sum the
  /// user typed last drives the other (e.g. a receipt total gives the liters).
  void _recalculate() {
    final price = double.tryParse(priceController.text) ?? 0;
    if (price <= 0) return;
    if (_sumIsSource) {
      final sum = double.tryParse(sumController.text);
      volumeController.text = sum == null ? '' : _formatNumber(sum / price);
    } else {
      final volume = double.tryParse(volumeController.text);
      sumController.text = volume == null ? '' : _formatNumber(volume * price);
    }
  }

  String _formatNumber(double value) {
    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
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
    final electric = _isElectric;
    final stations = await _fetchNearbyGasStations(current);
    // The user may have switched fuel / electricity while this was loading.
    if (!mounted || electric != _isElectric) return;

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
      return await _gasService.fetchNearbyGasStations(current, electric: _isElectric);
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
    final totalCost = double.tryParse(sumController.text) ?? volume * pricePerLiter;

    final record = FuelRecord(
      fuelType: selectedFuel.name,
      volume: volume,
      cost: totalCost,
      date: selectedDate!,
      mileage: mileage,
      currency: context.read<SettingsCubit>().state.currency,
      fullTank: _fullTank,
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
              icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 50),
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
                            title: _isElectric ? S.of(context).charging_nearby : null,
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
                                Icon(
                                  _isElectric ? Icons.ev_station : Icons.local_gas_station,
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
                                            ? (_isElectric
                                                  ? S.of(context).no_nearby_charger
                                                  : S.of(context).no_nearby_station)
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
              FuelType.Electric,
            ],
            selectedFuel: selectedFuel,
            onSelected: _onFuelSelected,
          ),

          AppSpacers.verticalMediumLarge,
          FuelPriceVolumeSumRow(
            volumeController: volumeController,
            priceController: priceController,
            sumController: sumController,
            onPriceChanged: _onPriceChanged,
            onVolumeChanged: _onVolumeChanged,
            onSumChanged: _onSumChanged,
            priceFocusNode: _priceFocusNode,
            volumeFocusNode: _volumeFocusNode,
            electric: _isElectric,
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onFullTankChanged(!_fullTank),
            child: Row(
              children: [
                Checkbox(value: _fullTank, onChanged: (value) => _onFullTankChanged(value ?? false)),
                Expanded(
                  child: Text(
                    _isElectric ? S.of(context).full_charge : S.of(context).full_tank,
                    style: textTheme.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          if (_fullTank)
            AppFieldCard(
              label: _isElectric ? S.of(context).battery_capacity_kwh : S.of(context).tank_volume_liters,
              child: TextField(
                controller: tankController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "0",
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black87),
                onChanged: _onTankVolumeChanged,
              ),
            ),

          AppSpacers.verticalXLarge,
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
