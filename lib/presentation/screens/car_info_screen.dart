import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';

@RoutePage()
class CarInfoScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const CarInfoScreen({super.key, this.onClose});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final _carNumberController = TextEditingController();
  final _techPassportController = TextEditingController();

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                const Text(
                  'Додавання авто',
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
                          const Text(
                            'Номер авто',
                            style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _carNumberController,
                            style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w400),
                            inputFormatters: [VehicleNumberFormatter(mapLatinToCyrillic: true)],
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            maxLength: 8,
                            decoration: InputDecoration(
                              hintText: 'АН0000НА',
                              hintStyle: TextStyle(fontSize: 28, color: Colors.grey, fontWeight: FontWeight.w400),
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
                          const Text(
                            'Номер техпаспорта',
                            style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _techPassportController,
                            style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w400),
                            inputFormatters: [TechPassportFormatter()],
                            maxLength: 9,
                            decoration: InputDecoration(
                              hintText: 'ХЕ 128436',
                              hintStyle: TextStyle(fontSize: 28, color: Colors.grey, fontWeight: FontWeight.w400),
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
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Пошук', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
