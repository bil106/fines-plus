import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class FineCheckScreen extends StatefulWidget {
  final String carNumber;
  final VoidCallback? onFineCheck;
  const FineCheckScreen({super.key, this.onFineCheck, required this.carNumber});

  @override
  State<FineCheckScreen> createState() => _FineCheckScreenState();
}

class _FineCheckScreenState extends State<FineCheckScreen> {
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
                Text(
                  S.of(context).check_fine_title,
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
                          const SizedBox(height: 12),
                          Text(
                            widget.carNumber,
                            style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '340 грн',
                            style: TextStyle(fontSize: 58, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '10 листопада 2024',
                            style: TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Container(height: 3, color: Colors.grey.shade100),
                          const SizedBox(height: 12),
                          const Text(
                            'Перевищення швидкості',
                            style: TextStyle(fontSize: 26, color: Colors.black87, fontWeight: FontWeight.w500),
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
                    child: Text(S.of(context).pay, style: TextStyle(fontSize: 24)),
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
