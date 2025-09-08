import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/date_picker_card.dart';
import 'package:fines_plus/core/widgets/fuel_amount_card.dart';
import 'package:fines_plus/core/widgets/fuel_choice_chips.dart';
import 'package:fines_plus/core/widgets/fuel_input_card.dart';
import 'package:fines_plus/core/widgets/mileage_card.dart';
import 'package:fines_plus/presentation/screens/fuel_map_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String selectedFuel = "АИ-95+";
  final TextEditingController volumeController = TextEditingController();
  Map<String, dynamic>? _bestStation;
  TextEditingController mileageController = TextEditingController();
  final Map<String, int> fuelPrices = {"АИ-98": 60, "АИ-95+": 62, "АИ-95": 55, "АИ-92": 47, "Газ LPG": 30};
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    _initLocationAndStation();
  }

  Future<void> _initLocationAndStation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng current = LatLng(position.latitude, position.longitude);

      final bestStation = await fetchBestNearbyGasStation(current, 'AIzaSyD8El-2EaU3iDuHLre3_Mz218iU-l1sr48');

      setState(() {
        _bestStation = bestStation;
      });
    } catch (e) {
      if (kDebugMode) print("❌ Помилка отримання позиції: $e");
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
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
          actions: [
IconButton(
              icon: const Icon(Icons.check, color: AppColors.blue700),
              onPressed: () {
                if (selectedDate == null || volumeController.text.isEmpty || mileageController.text.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Заполните дату, пробег и количество топлива")));
                  return;
                }

                final volume = double.tryParse(volumeController.text) ?? 0;
                final mileage = int.tryParse(mileageController.text) ?? 0;
                final pricePerLiter = fuelPrices[selectedFuel] ?? 0;
                final totalCost = volume * pricePerLiter;

                final record = FuelRecord(
                  fuelType: selectedFuel,
                  volume: volume,
                  cost: totalCost,
                  date: "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
                  mileage: mileage,
                );

                Navigator.pop(context, record);
              },
            )




          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fuel Up", style: textTheme.title),

              Row(
                children: [
                  _bestStation == null
                      ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2))
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FuelMapScreen(
                                  focusPosition: LatLng(_bestStation!['lat'], _bestStation!['lng']),
                                  focusName: _bestStation!['name'],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue, size: 40),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  _bestStation!['name'] ?? 'Заправка',
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
                  Expanded(child: MileageCard(textTheme: textTheme, controller: mileageController)),
                ],
              ),

              AppSpacers.verticalMedium,

              Text("Fuel", style: textTheme.subtitleText),
              AppSpacers.verticalMedium,
              FuelChoiceChips(
                fuels: fuelPrices.keys.toList(),
                selectedFuel: selectedFuel,
                onSelected: (fuel) => setState(() => selectedFuel = fuel),
              ),
              AppSpacers.verticalLarge,

              FuelInputCard(controller: volumeController, fuel: selectedFuel, price: fuelPrices[selectedFuel] ?? 0),

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
