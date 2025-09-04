import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/fuel_station_cubit.dart';
import 'package:core_cubit/cubit/fuel_station_state.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  TextEditingController mileageController = TextEditingController();
  final Map<String, int> fuelPrices = {"АИ-98": 60, "АИ-95+": 62, "АИ-95": 55, "АИ-92": 47, "Газ LPG": 30};
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    context.read<FuelStationCubit>().loadBestStation();
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

              BlocBuilder<FuelStationCubit, FuelStationState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (state.bestStation == null) {
                    return Text("Заправки не знайдено", style: textTheme.bodyMedium);
                  }
                  final station = state.bestStation!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FuelMapScreen(
                            focusPosition: LatLng(station['lat'], station['lng']),
                            focusName: station['name'],
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
                            station['name'] ?? 'Заправка',
                            style: textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
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
                  );
                },
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
                  Expanded(child: MileageCard(textTheme: textTheme)),
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
}
