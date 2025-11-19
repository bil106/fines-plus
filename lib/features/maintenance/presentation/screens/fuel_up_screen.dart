import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_amount_card.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_choice_chips.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_input_card.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

@RoutePage()
class FuelUpScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const FuelUpScreen({super.key, this.onBack});

  @override
  State<FuelUpScreen> createState() => _FuelUpScreenState();
}

class _FuelUpScreenState extends State<FuelUpScreen> {
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  FuelType selectedFuel = FuelType.Ai95;
  DateTime? selectedDate;
  GasStation? _bestStation;

  late final GasStationService _gasService;

  @override
  void initState() {
    super.initState();
    _gasService = GasStationService(Env.mapApiKey);
    _initLocationAndStation();
    _loadLastPrice(selectedFuel);
  }

  @override
  void dispose() {
    volumeController.dispose();
    mileageController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _loadLastPrice(FuelType fuel) async {
    final cached = await FuelPriceCache.getPrice(fuel.name);
    if (cached != null) {
      priceController.text = cached.toStringAsFixed(2);
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
    Location location = Location();

    if (!await location.serviceEnabled() && !await location.requestService()) return;
    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      return;
    }

    try {
      final locationData = await location.getLocation();
      final current = LatLng(locationData.latitude!, locationData.longitude!);

      final bestStation = await _fetchBestNearbyGasStation(current);
      setState(() => _bestStation = bestStation);
    } catch (e) {
      if (kDebugMode) print("Error getting position: $e");
    }
  }

  Future<GasStation?> _fetchBestNearbyGasStation(LatLng current) async {
    try {
      final stations = await _gasService.fetchNearbyGasStations(current);
      if (stations.isEmpty) return null;

      final highRated = stations.where((s) => s.rating >= 4.5).toList();
      if (highRated.isEmpty) return null;

      highRated.sort((a, b) {
        final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a.lat, a.lng);
        final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b.lat, b.lng);
        return distA.compareTo(distB);
      });

      return highRated.first;
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
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          leading: BackButton(color: Colors.blue.shade700, onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.blue, size: 50),
              onPressed: () {
                if (selectedDate == null || volumeController.text.isEmpty || mileageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.blue.shade700, content: Text(S.of(context).fill_date)),
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
                  currency: settingsCubit.state.currency,
                );

                context.router.pop(record);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).fuel_up, style: textTheme.headlineMedium),

              Row(
                children: [
                  _bestStation == null
                      ? const SizedBox(width: 200, child: Center(child: CircularProgressIndicator()))
                      : GestureDetector(
                          onTap: () {
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
                              const Icon(Icons.location_on, color: Colors.blueAccent, size: 40),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  _bestStation!.name,
                                  style: textTheme.bodySmall,
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FuelMapScreen()));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DatePickerCard(
                      selectedDate: selectedDate,
                      onDateSelected: (date) => setState(() => selectedDate = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MileageCard(textTheme: textTheme, controller: mileageController),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(S.of(context).fuel, style: textTheme.subtitleText),
              const SizedBox(height: 12),

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

              const SizedBox(height: 24),
              FuelInputCard(
                fuel: selectedFuel,
                volumeController: volumeController,
                priceController: priceController,
                onPriceChanged: _onPriceChanged,
              ),

              const SizedBox(height: 24),
              FuelAmountCard(volumeController: volumeController, priceController: priceController),

              const SizedBox(height: 40),
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
