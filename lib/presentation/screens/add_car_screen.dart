import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class AddCarScreen extends StatefulWidget {
  final VoidCallback? onOpenCarInfo;
  const AddCarScreen({super.key, this.onOpenCarInfo});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.grey.shade50, statusBarIconBrightness: Brightness.dark),
      child: Container(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 26),
                  Text(
                    S.of(context).add_cars,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: screenHeight * 0.6,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_rounded, color: Colors.blue.shade700, size: 176),
                            const SizedBox(height: 44),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.onOpenCarInfo != null) {
                                    widget.onOpenCarInfo!.call();
                                  } else {
                                    context.router.push(CarInfoRoute());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Text(S.of(context).add_cars, style: TextStyle(fontSize: 24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
