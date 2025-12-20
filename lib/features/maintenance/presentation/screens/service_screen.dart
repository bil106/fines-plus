import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/cost_summary.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import '../../../../../env/env.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
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
class ServiceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ServiceScreen({super.key, this.onBack});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final List<TextEditingController> serviceControllers = [TextEditingController()];
  final List<FocusNode> serviceFocusNodes = [FocusNode()];
  final TextEditingController costController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();

  Map<String, dynamic>? _bestStation;
  DateTime? selectedDate;

  final List<double> servicePricesUah = [0.0];
  double manualAmountUah = 0.0;

  @override
  void initState() {
    super.initState();
    _initLocationAndService();
  }

  @override
  void dispose() {
    for (final c in serviceControllers) {
      c.dispose();
    }
    for (final f in serviceFocusNodes) {
      f.dispose();
    }
    costController.dispose();
    mileageController.dispose();
    super.dispose();
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
      final locationData = await location.getLocation();
      final current = LatLng(locationData.latitude!, locationData.longitude!);

      final bestStation = await fetchBestNearbyService(current, Env.mapApiKey);
      if (!mounted) return;
      setState(() => _bestStation = bestStation);
    } catch (e) {
      if (kDebugMode) print("Error getting position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.energyBlue50,
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
              icon: const Icon(Icons.check, color: AppColors.blue700, size: 50),
              onPressed: _saveServiceRecords,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).service, style: textTheme.title),
              _buildBestStationRow(textTheme),
              const Divider(),
              _buildDateAndMileageRow(textTheme),
              AppSpacers.verticalMedium,
              Text(S.of(context).selecting_service, style: textTheme.subtitleText),
              AppSpacers.verticalMedium,
              _buildServiceFields(textTheme, settingsCubit),
              Center(
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: AppColors.energyBlue,
                    child: Icon(Icons.add, color: AppColors.neutreBlanc),
                  ),
                  onPressed: () {
                    setState(() {
                      serviceControllers.add(TextEditingController());
                      serviceFocusNodes.add(FocusNode());
                      servicePricesUah.add(0.0);
                    });
                  },
                ),
              ),
              AppSpacers.verticalMediumLarge,
              CostSummary(
                servicePricesUah: servicePricesUah,
                manualAmountUah: manualAmountUah,
                onManualUahChanged: (uah) {
                  setState(() {
                    manualAmountUah = uah;
                  });
                },
                convertFromUAH: (uah) => settingsCubit.convertFromUAH(uah),
                convertToUAH: (enteredInDisplayCurrency) => settingsCubit.convertToUAH(enteredInDisplayCurrency),
                currencyLabel: settingsCubit.getCurrencyLabel(context, settingsCubit.state.currency),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestStationRow(TextTheme textTheme) {
    return Row(
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
    );
  }

  Widget _buildDateAndMileageRow(TextTheme textTheme) {
    return Row(
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
    );
  }

  Widget _buildServiceFields(TextTheme textTheme, SettingsCubit settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radiusLarge,
        border: Border.all(color: AppColors.grey300, width: 2),
      ),
      child: Column(
        children: List.generate(serviceControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    textEditingController: serviceControllers[index],
                    focusNode: serviceFocusNodes[index],

                    optionsBuilder: (value) {
                      if (value.text.isEmpty) return ServiceList.names;
                      return ServiceList.names.where(
                        (option) => option.toLowerCase().startsWith(value.text.toLowerCase()),
                      );
                    },
                    onSelected: (val) {
                      final selectedItem = ServiceList.serviceItems.firstWhere(
                        (item) => item.name == val,
                        orElse: () => ServiceItem(name: val, priceUSD: 0),
                      );
                      final converted = settings.currencyService.convert(
                        selectedItem.priceUSD,
                        "UAH",
                        fromCurrency: "USD",
                      );
                      setState(() {
                        servicePricesUah[index] = converted;
                        final total = servicePricesUah.fold<double>(0.0, (a, b) => a + b) + manualAmountUah;
                        costController.text = total.toStringAsFixed(0);
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: S.of(context).select_a_service,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: const Icon(Icons.build, color: AppColors.blueAccent),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.red),
                            onPressed: () {
                              setState(() {
                                final removedC = serviceControllers.removeAt(index);
                                final removedF = serviceFocusNodes.removeAt(index);
                                removedC.dispose();
                                removedF.dispose();

                                servicePricesUah.removeAt(index);

                                final total = servicePricesUah.fold<double>(0.0, (a, b) => a + b) + manualAmountUah;
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
    );
  }

  void _saveServiceRecords() {
    if (selectedDate == null || serviceControllers.every((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(backgroundColor: AppColors.blue700, content: Text(S.of(context).select_service)));
      return;
    }

    final mileage = int.tryParse(mileageController.text) ?? 0;

    final records = <ServiceRecord>[];

    for (int i = 0; i < serviceControllers.length; i++) {
      final name = serviceControllers[i].text.trim();
      if (name.isEmpty) continue;

      final selectedService = ServiceList.serviceItems.firstWhere(
        (item) => item.name == name,
        orElse: () => ServiceItem(name: name, priceUSD: 0),
      );

      final costUah = (i < servicePricesUah.length) ? servicePricesUah[i] : 0.0;

      records.add(
        ServiceRecord(
          serviceName: selectedService.name,
          cost: costUah,
          date: "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
          mileage: mileage,
          currency: 'UAH',
        ),
      );
    }

    if (manualAmountUah > 0) {
      bool assigned = false;
      for (int i = 0; i < records.length; i++) {
        if ((records[i].cost == 0 || records[i].cost == 0.0) && records[i].serviceName.trim().isNotEmpty) {
          records[i] = ServiceRecord(
            serviceName: records[i].serviceName,
            cost: records[i].cost + manualAmountUah,
            date: records[i].date,
            mileage: records[i].mileage,
            currency: records[i].currency,
          );
          assigned = true;
          break;
        }
      }

      if (!assigned) {
        records.add(
          ServiceRecord(
            serviceName: "",
            cost: manualAmountUah,
            date: "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
            mileage: mileage,
            currency: 'UAH',
          ),
        );
      }
    }

    Navigator.pop(context, records);
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
}
