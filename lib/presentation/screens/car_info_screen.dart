import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/car_info_cubit.dart';
import 'package:core_cubit/cubit/car_info_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final ValueChanged<String>? onCheckFine;
  const CarInfoScreen({super.key, this.onCheckFine});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CarInfoCubit(context.read<CarInfoRepository>()),
      child: _CarInfoView(onCheckFine: onCheckFine),
    );
  }
}

class _CarInfoView extends StatefulWidget {
  final ValueChanged<String>? onCheckFine;
  const _CarInfoView({this.onCheckFine});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    final cubit = context.read<CarInfoCubit>();
    cubit.stream.listen((state) {
      _carNumberController.text = state.carNumber;
      _techPassportController.text = state.techPassport;
    });
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarInfoCubit>();
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              Text(
                S.of(context).addition_cars,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: screenHeight * 0.38,
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).car_number,
                          style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          onChanged: cubit.setCarNumber,
                          style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w400),
                          inputFormatters: [VehicleNumberFormatter(mapLatinToCyrillic: true)],
                          textCapitalization: TextCapitalization.characters,
                          keyboardType: TextInputType.text,
                          maxLength: 8,
                          decoration: InputDecoration(
                            hintText: 'АН0000НА',
                            hintStyle: const TextStyle(fontSize: 28, color: Colors.grey, fontWeight: FontWeight.w400),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          S.of(context).reg_number,
                          style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          onChanged: cubit.setTechPassport,
                          style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w400),
                          inputFormatters: [TechPassportFormatter()],
                          maxLength: 9,
                          decoration: InputDecoration(
                            hintText: 'ХЕ 128436',
                            hintStyle: const TextStyle(fontSize: 28, color: Colors.grey, fontWeight: FontWeight.w400),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              BlocBuilder<CarInfoCubit, CarInfoState>(
                builder: (context, state) {
                  final cubit = context.read<CarInfoCubit>();
                  return SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: cubit.isFormValid
                          ? () {
                              final error = cubit.validate();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                              } else {
                                widget.onCheckFine?.call(state.carNumber);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(S.of(context).search, style: TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
