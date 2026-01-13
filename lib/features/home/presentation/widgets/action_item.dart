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
    final Color inactiveColor = AppColors.neutreGrey;

    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.neutreGrey100,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? activeColor : Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: isSelected ? activeColor : inactiveColor),

              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? activeColor : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
