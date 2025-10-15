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
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_input_card.dart' ;
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  FuelType selectedFuel = FuelType.ai95;
  DateTime? selectedDate;
  Map<String, dynamic>? _bestStation;

  @override
  void initState() {
    super.initState();
    _initLocationAndStation();
    _loadLastPrice(selectedFuel);
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

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    try {
      LocationData locationData = await location.getLocation();
      LatLng current = LatLng(locationData.latitude!, locationData.longitude!);

      final bestStation = await fetchBestNearbyGasStation(current, Env.mapApiKey);

      setState(() {
        _bestStation = bestStation;
      });
    } catch (e) {
      if (kDebugMode) print("Error getting position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.grey50, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        appBar: AppBar(
          backgroundColor: AppColors.grey50,
          elevation: 0,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.blue700, size: 50),
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
                  date: "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
                  mileage: mileage,
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
              Text(S.of(context).fuel_up, style: textTheme.title),

          
              Row(
                children: [
                  _bestStation == null
                      ? AppLoaders.medium
                      : GestureDetector(
                          onTap: () {
                            context.router.push(
                              FuelMapRoute(
                                focusPosition: LatLng(_bestStation!['lat'], _bestStation!['lng']),
                                focusName: _bestStation!['name'],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: AppColors.energyBlue, size: 40),
                              AppSpacers.horizontalSmallMedium,
                              SizedBox(
                                width: 180,
                                child: Text(
                                  _bestStation!['name'] ?? S.of(context).fuel_up,
                                  style: Theme.of(context).textTheme.bodyMedium,
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

              AppSpacers.verticalMedium,

             
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

              AppSpacers.verticalMedium,

          
              Text(S.of(context).fuel, style: textTheme.subtitleText),
              AppSpacers.verticalMedium,
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

              AppSpacers.verticalLarge,

              FuelInputCard(
                fuel: selectedFuel,
                volumeController: volumeController,
                priceController: priceController,
                onPriceChanged: _onPriceChanged,
              ),

              AppSpacers.verticalLarge,

              FuelAmountCard(volumeController: volumeController, priceController: priceController),

              AppSpacers.verticalMaxMassive,
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  
  Future<Map<String, dynamic>?> fetchBestNearbyGasStation(LatLng current, String apiKey) async {
    final stations = await fetchNearbyGasStations(current, apiKey);
    if (stations.isEmpty) return null;

    final highRated = stations.where((s) => (s['rating'] ?? 0) >= 4.5).toList();
    if (highRated.isEmpty) return null;

    highRated.sort((a, b) {
      final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a['lat'], a['lng']);
      final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b['lat'], b['lng']);
      return distA.compareTo(distB);
    });

    return highRated.first;
  }
}

