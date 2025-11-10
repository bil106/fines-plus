import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';



class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.oil_barrel,
      Icons.water_drop,
      Icons.settings,
      Icons.build_circle,
      Icons.battery_full,
      Icons.tune,
      Icons.tire_repair,
      Icons.umbrella_outlined,
    ];

    final labels = [S.of(context).oil_icon, S.of(context).coolant_icon, S.of(context).service_icon,
      S.of(context).repair_icon, S.of(context).battery, S.of(context).tuning, S.of(context).tires_icon, S.of(context).insurance,
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: icons.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        return _ActionItem(
          icon: icons[index],
          label: labels[index],
          onTap: () {
            
          },
        );
      },
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.primaryColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
