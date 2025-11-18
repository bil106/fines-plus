import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/additional_options_widget.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';

import 'package:fines_plus/features/maintenance/presentation/screens/service_map_screen.dart';
import 'package:fines_plus/features/registration/data/datasources/iextract_tokens_usecase.dart';
import 'package:fines_plus/features/registration/data/models/flutter_secure_storage.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class ServiceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ServiceScreen({super.key, this.onBack});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final List<TextEditingController> serviceControllers = [TextEditingController()];
  final TextEditingController costController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();

  bool showAdditionalOptions = false;
  File? selectedPhoto;
  Map<String, dynamic>? _bestStation;
  DateTime? selectedDate;

  double usdToUahRate = 40.0;
  Map<int, double> selectedPricesUah = {};

  late final TokensRepositoryImpl _tokensRepository;
  late final ExtractTokensUseCase _extractTokensUseCase;

  @override
  void initState() {
    super.initState();
    _tokensRepository = TokensRepositoryImpl(const FlutterSecureStorage());
    _extractTokensUseCase = ExtractTokensUseCase(_tokensRepository);

    _initLocationAndService();
    _fetchRate();
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

      setState(() => _bestStation = bestStation);
    } catch (e) {
      if (kDebugMode) print("Error getting position: $e");
    }
  }

  Future<void> _fetchRate() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.nbuRateUSD));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final newRate = (data[0]['rate'] as num).toDouble();
          setState(() {
            usdToUahRate = newRate;

            selectedPricesUah.updateAll((key, oldValue) {
              final serviceName = serviceControllers[key].text;
              final selectedItem = ServiceList.serviceItems.firstWhere(
                (item) => item.name == serviceName,
                orElse: () => ServiceItem(name: serviceName, priceUSD: 0),
              );
              return selectedItem.priceUSD * usdToUahRate;
            });

            final total = selectedPricesUah.values.fold(0.0, (a, b) => a + b);
            costController.text = total.toStringAsFixed(0);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print(" Course loading error: $e");
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
              _buildServiceFields(textTheme),
              Center(
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: AppColors.energyBlue,
                    child: Icon(Icons.add, color: AppColors.neutreBlanc),
                  ),
                  onPressed: () {
                    setState(() => serviceControllers.add(TextEditingController()));
                  },
                ),
              ),
              AppSpacers.verticalMediumLarge,
              _buildCostSummary(textTheme),
              const Divider(),

              AdditionalOptionsWidget(
                cubit: AdditionalOptionsCubit(
                  tokensRepository: _tokensRepository,
                  extractTokensUseCase: _extractTokensUseCase,
                ),
              ),
            ],
          ),
        ),
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

    final records = serviceControllers.where((c) => c.text.isNotEmpty).map((c) {
      final selectedService = ServiceList.serviceItems.firstWhere(
        (item) => item.name == c.text,
        orElse: () => ServiceItem(name: c.text, priceUSD: 0),
      );
      return ServiceRecord(
        serviceName: selectedService.name,
        cost: selectedService.priceUSD * usdToUahRate,
        date: "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
        mileage: mileage,
      );
    }).toList();

    Navigator.pop(context, records);
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
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServiceMapScreen())),
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

  Widget _buildServiceFields(TextTheme textTheme) {
    return Column(
      children: List.generate(serviceControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return ServiceList.names;
                    return ServiceList.names.where(
                      (option) => option.toLowerCase().startsWith(value.text.toLowerCase()),
                    );
                  },
                  onSelected: (val) {
                    serviceControllers[index].text = val;

                    final selectedItem = ServiceList.serviceItems.firstWhere(
                      (item) => item.name == val,
                      orElse: () => ServiceItem(name: val, priceUSD: 0),
                    );

                    selectedPricesUah[index] = selectedItem.priceUSD * usdToUahRate;

                    setState(() {});
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    serviceControllers[index] = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: S.of(context).select_a_service,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.build, color: AppColors.blueAccent),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.delete, color: AppColors.red),
                          onPressed: () {
                            setState(() {
                              serviceControllers.removeAt(index);
                              selectedPricesUah.remove(index);
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
    );
  }

  Widget _buildCostSummary(TextTheme textTheme) {
    final settingsCubit = context.watch<SettingsCubit>();
    final currency = settingsCubit.state.currency;
    final symbol = settingsCubit.getCurrencyLabel(context, currency);

    final totalUah = selectedPricesUah.values.fold(0.0, (a, b) => a + b);

    final convertedTotal = settingsCubit.convertFromUAH(totalUah);

    final displayController = TextEditingController(text: convertedTotal.toStringAsFixed(0));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutreGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: AppColors.blueAccent),
              AppSpacers.horizontalSmallMedium,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).cost_of_work),
                  SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: displayController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                              border: InputBorder.none,
                            ),
                            style: textTheme.black16,
                            onChanged: (val) {
                              final entered = double.tryParse(val) ?? 0;

                              final manualUah = settingsCubit.convertFromUAH(entered);
                              setState(() {
                                selectedPricesUah[selectedPricesUah.length - 1] = manualUah;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(symbol, style: textTheme.black16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpacers.horizontalXXMassive,

          Row(
            children: [
              const Icon(Icons.attach_money, color: AppColors.blueAccent),
              AppSpacers.horizontalSmallMedium,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).total_amount),
                  Text("${convertedTotal.toStringAsFixed(0)} $symbol", style: textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ],
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
