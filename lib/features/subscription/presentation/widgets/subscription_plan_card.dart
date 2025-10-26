import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/subscription/data/models/fake_product.dart';
import 'package:flutter/material.dart';


class SubscriptionPlanCard extends StatelessWidget {
  final FakeProduct product;
  final int months;
  final bool isSelected;
  final VoidCallback onBuy;

  const SubscriptionPlanCard({
    super.key,
    required this.product,
    required this.months,
    required this.isSelected,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    int activeFeatures = 1;
    if (months == 6) activeFeatures = 2;
    if (months == 12) activeFeatures = 3;

    final allFeatures = ["Access to basic features", "Ad-free experience", "Premium support"];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.blue700 : Colors.transparent, width: isSelected ? 3 : 1),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.blue700.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
            : const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        color: AppColors.energyBlue50,
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.blue700,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(product.title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allFeatures.asMap().entries.map((entry) {
                  final index = entry.key;
                  final feature = entry.value;
                  final isActive = index < activeFeatures;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          color: isActive ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: isActive ? Colors.black : Colors.grey,
                              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.blue700 : AppColors.blue700.withOpacity(0.8),
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isSelected ? "Selected" : "Select Plan",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
