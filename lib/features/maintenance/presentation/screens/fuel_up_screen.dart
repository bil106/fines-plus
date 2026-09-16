import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_amount_card.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_choice_chips.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_input_card.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
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
  const FuelUpScreen({super.key, this.onBack});

  @override
  State<FuelUpScreen> createState() => _FuelUpScreenState();
}

class _FuelUpScreenState extends State<FuelUpScreen> {
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
  bool _isLoadingBestStation = true;

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
          print('FuelUpScreen: geolocation unavailable, using fallback position');
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
    final bestStation = await _fetchBestNearbyGasStation(current);
    if (!mounted) return;
    setState(() {
      _bestStation = bestStation;
      _isLoadingBestStation = false;
    });
  }

  Future<GasStation?> _fetchBestNearbyGasStation(LatLng current) async {
    try {
      final stations = await _gasService.fetchNearbyGasStations(current);
      if (stations.isEmpty) return null;

      double distanceTo(GasStation s) =>
          Geolocator.distanceBetween(current.latitude, current.longitude, s.lat, s.lng);

      // Prefer well-rated stations, but a 4.5+ bar routinely excluded every
      // station in the area — never come back empty just because none
      // happen to clear a high bar; fall back to the nearest one instead.
      final wellRated = stations.where((s) => s.rating >= 4.0).toList();
      final candidates = wellRated.isNotEmpty ? wellRated : stations;

      candidates.sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));

      return candidates.first;
    } catch (e) {
      if (kDebugMode) print("Error fetching stations: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          elevation: 0,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.blue, size: 50),
              onPressed: () {
                if (selectedDate == null || volumeController.text.isEmpty || mileageController.text.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(backgroundColor: AppColors.blue700, content: Text(S.of(context).fill_date)));
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
                  currency: settingsCubit.state.currency,
                );

                // This screen is reached both as a pushed route (Maintenance
                // FAB) and as a static PageView page (main "Заправка" tile),
                // where nothing awaits a popped value — so it must save the
                // record itself rather than relying on a caller to do it.
                context.read<MaintenanceCubit>().addFuelRecord(record);

                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (context.router.canPop()) {
                  context.router.pop(record);
                } else {
                  Navigator.of(context).maybePop(record);
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).fuel_up, style: textTheme.title),

              Row(
                children: [
                  if (_isLoadingBestStation)
                    const SizedBox(width: 200, child: Center(child: CircularProgressIndicator()))
                  else
                    GestureDetector(
                          onTap: () {
                            if (_bestStation == null) return;
                            context.router.push(
                              FuelMapRoute(
                                focusPosition: LatLng(_bestStation!.lat, _bestStation!.lng),
                                focusName: _bestStation!.name,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: AppColors.blueAccent, size: 40),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  _bestStation?.name ?? S.of(context).no_nearby_station,
                                  style: _bestStation == null
                                      ? textTheme.captionStrong.copyWith(fontWeight: FontWeight.normal)
                                      : textTheme.captionStrong,
                                  maxLines: _bestStation == null ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                  const Spacer(),
                  IconButton(
                    icon: Image.asset('assets/icons/map.png', width: 40, height: 40),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _bestStation == null
                              ? const FuelMapScreen()
                              : FuelMapScreen(
                                  focusPosition: LatLng(_bestStation!.lat, _bestStation!.lng),
                                  focusName: _bestStation!.name,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              AppSpacers.verticalXSmall,

              Row(
                children: [
                  Expanded(
                    child: DatePickerCard(selectedDate: selectedDate, onDateSelected: _onDateSelected),
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
              Text(S.of(context).fuel, style: textTheme.subtitleText),
              AppSpacers.verticalXSmall,

              FuelChoiceChips(
                fuels: fuelPrices.keys.toList(),
                selectedFuel: selectedFuel,
                onSelected: (fuel) {
                  setState(() {
                    selectedFuel = fuel;
                    _loadLastPrice(fuel);
                  });
                },
              ),

              AppSpacers.verticalMediumLarge,
              FuelInputCard(
                fuel: selectedFuel,
                volumeController: volumeController,
                priceController: priceController,
                onPriceChanged: _onPriceChanged,
                priceFocusNode: _priceFocusNode,
                volumeFocusNode: _volumeFocusNode,
              ),

              AppSpacers.verticalMediumLarge,
              FuelAmountCard(volumeController: volumeController, priceController: priceController),

              AppSpacers.verticalXLarge,
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
