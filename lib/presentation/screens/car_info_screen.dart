import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      child: Container(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  IconButton(
                //   icon: const Icon(Icons.arrow_back),
                //   onPressed: () {
                //     if (widget.onClose != null) {
                //       widget.onClose!();
                //     } else {
                      
                //       Navigator.maybePop(context);
                //     }
                //   },
                // ),
                const SizedBox(height: 26),
                const Text(
                  'Додавання авто',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: screenHeight * 0.4,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Номер авто',
                            style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _carNumberController,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              hintText: 'АН 0000НА',
                              hintStyle: TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.w400) ,
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Номер техпаспорта',
                            style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _techPassportController,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              hintText: 'Х128436',
                            hintStyle: TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.w400),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            ),
                          ),
                          const SizedBox(height: 24),
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
                    onPressed: () {
                   
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Пошук', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
          ),
        ),
      
    );
  }
}

