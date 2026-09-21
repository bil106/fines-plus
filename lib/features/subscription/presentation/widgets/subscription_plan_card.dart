import 'dart:ui';

import 'package:core_localization/generated/l10n.dart';
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
    final textTheme = Theme.of(context).textTheme;

    int activeFeatures = 1;
    if (months == 6) activeFeatures = 2;
    if (months == 12) activeFeatures = 3;

    final allFeatures = [S.of(context).access_basic, S.of(context).free_experience, S.of(context).premium_support];

    return GestureDetector(
      onTap: onBuy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.blue700, AppColors.blue700.withOpacity(0.4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.blue700.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6))]
              : [BoxShadow(color: AppColors.black12, blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [AppColors.neutreBlanc.withOpacity(0.9), AppColors.neutreBlanc.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: isSelected ? AppColors.blue700 : AppColors.grey600, size: 24),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          product.title,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.black),
                        ),
                      ),

                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.blue700, borderRadius: BorderRadius.circular(12)),
                          child: Text(S.of(context).selected, style: textTheme.labelSmall?.copyWith(color: AppColors.neutreBlanc)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// Price
                  Text(
                    "\$${product.price}",
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue700),
                  ),

                  Text('$months ${S.of(context).months}', style: textTheme.bodySmall?.copyWith(color: AppColors.grey600)),

                  const SizedBox(height: 16),

                  /// Features
                  ...allFeatures.asMap().entries.map((entry) {
                    final index = entry.key;
                    final feature = entry.value;
                    final isActive = index < activeFeatures;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.circle_outlined,
                            color: isActive ? AppColors.blue700 : AppColors.grey400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: isActive ? AppColors.black : AppColors.grey500,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 18),

                  /// Button
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedScale(
                      scale: isSelected ? 1.03 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: onBuy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          isSelected ? S.of(context).selected : S.of(context).select_plan,
                          style: textTheme.titleSmall?.copyWith(color: AppColors.neutreBlanc),
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
