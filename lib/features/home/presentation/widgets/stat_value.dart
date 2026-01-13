import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatValue extends StatelessWidget {
  final String value;
  final String label;

  const StatValue({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: textTheme.blue20W400),
        
        Text(label, style: textTheme.hintAnalitText),
      ],
    );
  }
}
