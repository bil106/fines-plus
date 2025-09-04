import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class FuelInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String fuel;
  final int price;

  const FuelInputCard({super.key, required this.controller, required this.fuel, required this.price});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, color: AppColors.blue700),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              showCursor: false,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "0 L",
              ),
            ),
          ),
          const SizedBox(width: 50),
          Icon(Icons.monetization_on_outlined, color: AppColors.blue700),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ціна за 1 літр:", style: textTheme.bodySmall?.copyWith(color: Colors.black87)),
              Text(
                "$price UAH",
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
