import 'package:auto_route/auto_route.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
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
                  Expanded(child: _buildDatePicker(textTheme)),
                  SizedBox(width: 16),
                  Expanded(child: MileageCard(textTheme: textTheme)),
                ],
              ),

              AppSpacers.verticalMedium,

              Text("Fuel", style: textTheme.subtitleText),
              AppSpacers.verticalMedium,
              Wrap(spacing: 6, children: fuelPrices.keys.map((fuel) => _fuelChip(fuel)).toList()),
              AppSpacers.verticalLarge,

              _buildFuelInput(volumeController, textTheme),

              AppSpacers.verticalLarge,

              _buildFuelAmount(volumeController, textTheme),
              AppSpacers.verticalMaxMassive,
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(TextTheme textTheme) {
    return SizedBox(
      height: 115,
      child: GestureDetector(
        onTap: () async {
          DateTime now = DateTime.now();
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? now,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 5),
          );
          if (picked != null) {
            setState(() {
              selectedDate = picked;
            });
          }
        },
        child: Card(
          color: AppColors.neutreBlanc,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Дата", style: textTheme.subtitleText.copyWith(fontSize: 14)),
                      AppSpacers.verticalXSmall,
                      Text(
                        selectedDate != null
                            ? "${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}"
                            : "Виберіть дату",
                        style: selectedDate != null
                            ? textTheme.historyText.copyWith(fontSize: 20)
                            : textTheme.hintText.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fuelChip(String label) {
    final isSelected = selectedFuel == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.blue700,
      backgroundColor: AppColors.neutreBlanc,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (_) => setState(() => selectedFuel = label),
      showCheckmark: false,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
    );
  }

  Widget _buildFuelInput(TextEditingController controller, TextTheme textTheme) {
    final price = fuelPrices[selectedFuel] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, color: AppColors.blue700),
          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              showCursor: false,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0 L",
              ),
            ),
          ),

          const SizedBox(width: 50),

          Icon(Icons.monetization_on_outlined, color: AppColors.blue700),
          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ціна за 1 літр:", style: textTheme.bodySmall?.copyWith(color: Colors.black87)),
              Text(
                "$price UAH",
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelAmount(TextEditingController controller, TextTheme textTheme) {
    final price = fuelPrices[selectedFuel] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, color: AppColors.blue700),
          const SizedBox(width: 8),

          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final liters = double.tryParse(value.text) ?? 0;
                final total = (liters * price).toStringAsFixed(2);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Сума:", style: textTheme.bodySmall?.copyWith(color: Colors.black87)),
                    Text(
                      "$total UAH",
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 50),

          GestureDetector(
            onTap: () {
              controller.text = "53";
            },
            child: Row(
              children: [
                Icon(Icons.water_drop_outlined, color: AppColors.blue700),
                const SizedBox(width: 8),
                Text(
                  "Full tank",
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                ),
              ],
            ),
          ),
        ],
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
