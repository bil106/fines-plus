import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_text_theme.dart';
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
    final textTheme = Theme.of(context).textTheme;
    int activeFeatures = 1;
    if (months == 6) activeFeatures = 2;
    if (months == 12) activeFeatures = 3;

    final allFeatures = [S.of(context).access_basic, S.of(context).free_experience, S.of(context).premium_support];

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
        color: AppColors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.blue700,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Text(
                    "\$${product.price}",
                    style:textTheme.whiteNormalBold
                  
                  ),
                  AppSpacers.verticalSmall,
                  Text(product.title, style: textTheme.white70fs16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
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
                          color: isActive ? AppColors.green : AppColors.energyBlue50,
                          size: 20,
                        ),
                        AppSpacers.horizontalSmallMedium,                       
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: isActive ? AppColors.black : AppColors.energyBlue50,
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
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isSelected ? S.of(context).selected : S.of(context).select_plan,
                  style: textTheme.whiteButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
