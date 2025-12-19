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

  static const _types = <InsuranceType>[
    InsuranceType(key: 'osago', title: 'ОСАГО', icon: Icons.policy),
    InsuranceType(key: 'kasko', title: 'КАСКО', icon: Icons.security),
    InsuranceType(key: 'green_card', title: 'Green Card', icon: Icons.public),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Выберите вид страховки', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ..._types.map((type) {
              final disabled = disabledTypes.contains(type.key);

              return ListTile(
                leading: Icon(type.icon, color: disabled ? Colors.grey : null),
                title: Text(type.title),
                subtitle: disabled ? const Text('Уже добавлена') : null,
                enabled: !disabled,
                onTap: disabled
                    ? null
                    : () {
                        Navigator.of(context).pop(type);
                      },
              );
            }),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          ],
        ),
      ),
    );
  }
}
