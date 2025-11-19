import 'package:auto_route/auto_route.dart';

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/core/helpers/format_currency.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_map_screen.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

@RoutePage()
class TuningScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const TuningScreen({super.key, this.onBack});

  @override
  State<TuningScreen> createState() => _TuningScreenState();
}

class _TuningScreenState extends State<TuningScreen> {
  final List<TextEditingController> tuningControllers = [TextEditingController()];
  final TextEditingController costController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  Map<String, dynamic>? _bestStation;
  DateTime? selectedDate;

  Map<int, double> selectedPricesUah = {};

  @override
  void initState() {
    super.initState();
    _initLocationAndService();
  }

  Future<void> _initLocationAndService() async {
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

      final bestStation = await fetchBestNearbyService(current, Env.mapApiKey);
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

    final settings = context.watch<SettingsCubit>();
    final currency = settings.state.currency;
    final currencyService = settings.currencyService;

    selectedPricesUah.values.fold(0.0, (sum, val) => sum + val);

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
                if (selectedDate == null || tuningControllers.every((c) => c.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: AppColors.blue700, content: Text(S.of(context).select_service)),
                  );
                  return;
                }

                final mileage = int.tryParse(mileageController.text) ?? 0;

                final List<TuningRecord> records = tuningControllers.where((c) => c.text.isNotEmpty).map((c) {
                  final selectedTuning = ServiceList.tuningItems.firstWhere(
                    (item) => item.name == c.text,
                    orElse: () => ServiceItem(name: c.text, priceUSD: 0),
                  );

                  final costUah = currencyService.convert(selectedTuning.priceUSD, "UAH", fromCurrency: "USD");

                  return TuningRecord(
                    tuningName: selectedTuning.name,
                    cost: costUah,
                    date: selectedDate!,
                    mileage: mileage, currency: 'UAH',
                  );
                }).toList();

                Navigator.pop(context, records);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).tuning, style: textTheme.title),
              Row(
                children: [
                  _bestStation == null
                      ? AppLoaders.medium
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ServiceMapScreen(
                                  focusPosition: LatLng(_bestStation!['lat'], _bestStation!['lng']),
                                  focusName: _bestStation!['name'],
                                ),
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
                                  _bestStation!['name'] ?? S.of(context).service_station,
                                  style: textTheme.bodyMedium,
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServiceMapScreen()));
                    },
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: DatePickerCard(
                      selectedDate: selectedDate,
                      onDateSelected: (date) => setState(() => selectedDate = date),
                    ),
                  ),
                  AppSpacers.horizontalMediumLarge,
                  Expanded(
                    child: MileageCard(textTheme: textTheme, controller: mileageController),
                  ),
                ],
              ),
              AppSpacers.verticalMedium,
              Text(S.of(context).selecting_service, style: textTheme.subtitleText),
              AppSpacers.verticalMedium,
              Column(
                children: List.generate(tuningControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty) return ServiceList.tuningItems.map((e) => e.name);
                              return ServiceList.tuningItems
                                  .map((e) => e.name)
                                  .where((option) => option.toLowerCase().startsWith(value.text.toLowerCase()));
                            },
                            onSelected: (val) {
                              tuningControllers[index].text = val;
                              final selectedItem = ServiceList.tuningItems.firstWhere(
                                (item) => item.name == val,
                                orElse: () => ServiceItem(name: val, priceUSD: 0),
                              );

                              selectedPricesUah[index] = currencyService.convert(
                                selectedItem.priceUSD,
                                "UAH",
                                fromCurrency: "USD",
                              );

                              double total = selectedPricesUah.values.fold(0, (a, b) => a + b);
                              costController.text = total.toStringAsFixed(0);

                              setState(() {});
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              tuningControllers[index] = controller;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: S.of(context).select_service,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.build, color: AppColors.blueAccent),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.red),
                                    onPressed: () {
                                      setState(() {
                                        tuningControllers.removeAt(index);
                                        selectedPricesUah.remove(index);
                                        double total = selectedPricesUah.values.fold(0, (a, b) => a + b);
                                        costController.text = total.toStringAsFixed(0);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              Center(
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: AppColors.energyBlue,
                    child: Icon(Icons.add, color: AppColors.neutreBlanc),
                  ),
                  onPressed: () {
                    setState(() {
                      tuningControllers.add(TextEditingController());
                    });
                  },
                ),
              ),
              AppSpacers.verticalMediumLarge,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutreGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: AppColors.blueAccent),
                        AppSpacers.horizontalSmallMedium,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).sum),
                            Text(
                              selectedPricesUah.isEmpty
                                  ? '0 $currency'
                                  : "${formatCurrency(selectedPricesUah.values.last, context, fromCurrency: 'UAH')} $currency",
                              style: textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: AppColors.blueAccent),
                        AppSpacers.horizontalSmallMedium,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).total_amount),
                            Text(
                              costController.text.isEmpty
                                  ? '0 $currency'
                                  : "${formatCurrency(double.tryParse(costController.text) ?? 0, context, fromCurrency: 'UAH')} $currency",
                              style: textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> fetchBestNearbyService(LatLng current, String apiKey) async {
  final stations = await fetchNearbyServices(current, apiKey);
  if (stations.isEmpty) return null;

  final highRated = stations.where((s) => (s['rating'] ?? 0) >= 4.0).toList();
  if (highRated.isEmpty) return null;

  highRated.sort((a, b) {
    final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a['lat'], a['lng']);
    final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b['lat'], b['lng']);
    return distA.compareTo(distB);
  });

  return highRated.first;
}
