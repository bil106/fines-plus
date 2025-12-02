import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/cost_input_card.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_map_screen.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

@RoutePage()
class CarWashScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CarWashScreen({super.key, this.onBack});

  @override
  State<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends State<CarWashScreen> {
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  DateTime? selectedDate;
  Map<String, dynamic>? _bestCarWash;

  @override
  void initState() {
    super.initState();
    _initLocationAndCarWash();
  }

  Future<void> _initLocationAndCarWash() async {
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
      final locationData = await location.getLocation();
      LatLng current = LatLng(locationData.latitude!, locationData.longitude!);

      final bestCarWash = await fetchBestNearbyCarWash(current, Env.mapApiKey);

      setState(() => _bestCarWash = bestCarWash);
    } catch (e) {
      if (kDebugMode) print("Error getting car wash: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: AppColors.grey50, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          elevation: 0,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.blue700, size: 50),
              onPressed: _saveRecord,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).car_wash, style: textTheme.title),
              const SizedBox(height: 16),

              Row(
                children: [
                  _bestCarWash == null
                      ? AppLoaders.medium
                      : GestureDetector(
                          onTap: () {
                            context.router.push(
                              CarWashMapRoute(
                                focusPosition: LatLng(_bestCarWash!['lat'], _bestCarWash!['lng']),
                                focusName: _bestCarWash!['name'],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_car_wash, color: AppColors.energyBlue, size: 40),
                              AppSpacers.horizontalSmallMedium,
                              SizedBox(
                                width: 180,
                                child: Text(
                                  _bestCarWash!['name'] ?? S.of(context).car_wash,
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CarWashMapScreen()));
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
              Text(S.of(context).price, style: textTheme.subtitleText),
              AppSpacers.verticalMedium,
              CostInputCard(controller: costController),

              AppSpacers.verticalXXGigantic,
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (selectedDate == null || mileageController.text.isEmpty || costController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(backgroundColor: AppColors.blue700, content: Text(S.of(context).fill_date)));
      return;
    }

    final mileage = int.tryParse(mileageController.text) ?? 0;
    final cost = double.tryParse(costController.text) ?? 0;

    final userId = 'default_user';

    final record = CarWashRecord(date: selectedDate!, mileage: mileage, amount: cost, userId: userId);

    context.router.pop(record);
  }

  Future<Map<String, dynamic>?> fetchBestNearbyCarWash(LatLng current, String apiKey) async {
    final washes = await fetchNearbyCarWashes(current, apiKey);
    if (washes.isEmpty) return null;

    final highRated = washes.where((s) => (s['rating'] ?? 0) >= 4.0).toList();
    if (highRated.isEmpty) return null;

    highRated.sort((a, b) {
      final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a['lat'], a['lng']);
      final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b['lat'], b['lng']);
      return distA.compareTo(distB);
    });

    return highRated.first;
  }
}
