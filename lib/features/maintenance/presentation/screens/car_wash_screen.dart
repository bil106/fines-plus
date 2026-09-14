import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/cost_input_card.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import '../../../../../env/env.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_map_screen.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class CarWashScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CarWashScreen({super.key, this.onBack});

  @override
  State<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends State<CarWashScreen> {
  static const LatLng _fallbackPosition = LatLng(50.4501, 30.5234);
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final FocusNode _mileageFocusNode = FocusNode();

  DateTime? selectedDate;
  Map<String, dynamic>? _bestCarWash;
  bool _isLoadingBestCarWash = true;

  @override
  void initState() {
    super.initState();
    _initLocationAndCarWash();
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
        await _loadBestCarWashFrom(_fallbackPosition);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 5));
      await _loadBestCarWashFrom(LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (kDebugMode) {
        print("Error getting car wash: $e");
      }
      await _loadBestCarWashFrom(_fallbackPosition);
    }
  }

  Future<void> _loadBestCarWashFrom(LatLng current) async {
    final bestCarWash = await fetchBestNearbyCarWash(current, Env.mapApiKey);
    if (!mounted) return;
    setState(() {
      _bestCarWash = bestCarWash;
      _isLoadingBestCarWash = false;
    });
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
                  _isLoadingBestCarWash
                      ? AppLoaders.medium
                      : GestureDetector(
                          onTap: () {
                            if (_bestCarWash == null) return;
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
                                  _bestCarWash?['name'] ?? S.of(context).car_wash,
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _bestCarWash == null
                              ? const CarWashMapScreen()
                              : CarWashMapScreen(
                                  focusPosition: LatLng(_bestCarWash!['lat'], _bestCarWash!['lng']),
                                  focusName: _bestCarWash!['name'],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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

    final ownerId = 'default_user';

    final record = CarWashRecord(date: selectedDate!, mileage: mileage, amount: cost, ownerId: ownerId);

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
