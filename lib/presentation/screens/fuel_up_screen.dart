import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/date_picker_card.dart';
import 'package:fines_plus/core/widgets/extensions/fuel_type.dart';
import 'package:fines_plus/core/widgets/fuel_amount_card.dart';
import 'package:fines_plus/core/widgets/fuel_choice_chips.dart';
import 'package:fines_plus/core/widgets/fuel_input_card.dart';
import 'package:fines_plus/core/widgets/mileage_card.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/presentation/screens/fuel_map_screen.dart';
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
  late final VoidCallback? onBack;

  Map<String, dynamic>? _bestStation;

  TextEditingController mileageController = TextEditingController();
  FuelType selectedFuel = FuelType.ai95Plus;

  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    _initLocationAndStation();
  }

  Future<void> _initLocationAndStation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (kDebugMode) print("❌ Location service not enabled");
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (kDebugMode) print("❌ Location permission not granted");
        return;
      }
    }

    try {
      LocationData locationData = await location.getLocation();
      LatLng current = LatLng(locationData.latitude!, locationData.longitude!);

      final bestStation = await fetchBestNearbyGasStation(current, Env.mapApiKey);

      setState(() {
        _bestStation = bestStation;
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error getting position: $e");
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
              icon: const Icon(Icons.check, color: AppColors.blue700,size: 50,),
              onPressed: () {
                if (selectedDate == null || volumeController.text.isEmpty || mileageController.text.isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).fill_date)));
                  return;
                }

                final volume = double.tryParse(volumeController.text) ?? 0;
                final mileage = int.tryParse(mileageController.text) ?? 0;
                final pricePerLiter = fuelPrices[selectedFuel] ?? 0;

                final totalCost = volume * pricePerLiter;

                final record = FuelRecord(
                  fuelType: selectedFuel.localized(context),
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

                  SizedBox(width: 16),
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
                onSelected: (fuel) => setState(() => selectedFuel = fuel),
              ),

              AppSpacers.verticalLarge,

              FuelInputCard(controller: volumeController, fuel: selectedFuel),

              AppSpacers.verticalLarge,

              FuelAmountCard(controller: volumeController, price: fuelPrices[selectedFuel] ?? 0),

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

    // We filter only highly rated ones
    final highRated = stations.where((s) => (s['rating'] ?? 0) >= 4.5).toList();
    if (highRated.isEmpty) return null;

    // Find the closest one
    highRated.sort((a, b) {
      final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a['lat'], a['lng']);
      final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b['lat'], b['lng']);
      return distA.compareTo(distB);
    });

    return highRated.first;
  }
}
