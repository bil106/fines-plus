import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
 @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            const Text(
              'Нагадування',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 140,),
                    ),
                    const SizedBox(height: 50),
                    const Text('На вас немає штрафів', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
