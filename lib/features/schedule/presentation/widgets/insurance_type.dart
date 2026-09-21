import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';


class InsuranceType {
  final String key; // osago / kasko / green_card
  final String title;
  final IconData icon;

  const InsuranceType({required this.key, required this.title, required this.icon});
}


class InsuranceTypePickerSheet extends StatelessWidget {
 
  final Set<String> disabledTypes;

  const InsuranceTypePickerSheet({super.key, this.disabledTypes = const {}});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final types = <InsuranceType>[
      InsuranceType(key: 'osago', title: l10n.insurance_osago, icon: Icons.policy),
      InsuranceType(key: 'kasko', title: l10n.insurance_kasko, icon: Icons.security),
      InsuranceType(key: 'green_card', title: l10n.insurance_green_card, icon: Icons.public),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).select_type_insurance, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...types.map((type) {
              final disabled = disabledTypes.contains(type.key);

              return ListTile(
                leading: Icon(type.icon, color: disabled ? AppColors.grey500 : null),
                title: Text(type.title),
                subtitle: disabled ?  Text(S.of(context).already_added) : null,
                enabled: !disabled,
                onTap: disabled
                    ? null
                    : () {
                        Navigator.of(context).pop(type);
                      },
              );
            }),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child:Text(S.of(context).cancel)),
          ],
        ),
      ),
    );
  }
}
