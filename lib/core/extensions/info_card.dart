import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;

  const InfoCard({super.key, required this.label, this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Flexible(
      fit: FlexFit.loose, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: textTheme.subtitleText.copyWith(fontSize: 14)),
          ),
          SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value ?? '-', style: textTheme.historyText.copyWith(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

