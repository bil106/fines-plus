import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final String labelKey;

  const ActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected,
    required this.labelKey,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = AppColors.energyBlue;
    final Color inactiveColor = Colors.grey.shade400;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? activeColor : Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(icon, size: 32, color: isSelected ? activeColor : inactiveColor),
              const SizedBox(height: 1),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: isSelected ? activeColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
