// ignore_for_file: file_names, unused_element

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MileageInputFormatter extends TextInputFormatter {
  final int max;
  MileageInputFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final value = int.tryParse(newValue.text) ?? 0;
    if (value > max) {
      return oldValue; 
    }
    return newValue;
  }
}

Widget _buildMileageCard(TextTheme textTheme) {
  TextEditingController? mileageController;
  return SizedBox(
    height: 115,
    child: Card(
      color: AppColors.neutreBlanc,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.speed, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.current.mileage,
                    style: textTheme.subtitleText.copyWith(fontSize: 14),
                  ),
                  TextField(
                    controller: mileageController,
                    keyboardType: TextInputType.number,
                    showCursor: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      MileageInputFormatter(max: 1000000),
                    ],
                    decoration: InputDecoration(
                      hintText: S.current.enter_mileage,
                      hintStyle: textTheme.hintText.copyWith(fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: InputBorder.none,
                      suffixText:S.current.km,
                      suffixStyle: textTheme.hintText.copyWith(fontSize: 16),
                    ),
                    style: textTheme.historyText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
