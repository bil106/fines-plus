import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnalyticsFuelField extends StatefulWidget {
  final double pricePerLiter;
  final VoidCallback? onTap;

  const AnalyticsFuelField({this.pricePerLiter = 45, this.onTap, super.key});

  @override
  State<AnalyticsFuelField> createState() => _AnalyticsFuelFieldState();
}

class _AnalyticsFuelFieldState extends State<AnalyticsFuelField> {
  final TextEditingController _litersController = TextEditingController();
  double _amount = 0;

  void _onLitersChanged(String value) {
    final liters = double.tryParse(value) ?? 0;
    setState(() {
      _amount = liters * widget.pricePerLiter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppBorders.radiusLarge),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: TextField(
              style: textTheme.historyText,
              controller: _litersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: S.of(context).enter_liters,
                hintStyle: textTheme.hintCaption,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: _onLitersChanged,
            ),
          ),
          const Spacer(),
          Text("${_amount.toStringAsFixed(0)} ₴", style: textTheme.historyText),
          AppSpacers.horizontalSmallMedium,
          GestureDetector(
            onTap: widget.onTap,
            child: const Icon(Icons.arrow_forward_ios, color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}
