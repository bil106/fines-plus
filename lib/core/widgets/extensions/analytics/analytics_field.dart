import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnalyticsField extends StatelessWidget {
  final TextEditingController controller;
  final Widget? trailing;

  const AnalyticsField({required this.controller, this.trailing, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(hintText: "Введіть пробіг", hintStyle: textTheme.hintAnalitText, focusedBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              style: textTheme.historyText
            ),
          ),
          if (trailing != null) trailing!,
          Icon(Icons.info_outline, color: Colors.grey,size: 35,),
        ],
      ),
    );
  }
}
