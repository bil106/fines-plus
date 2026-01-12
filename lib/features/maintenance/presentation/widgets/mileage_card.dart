import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core_utils/formatters/mileageInput_formatter.dart';

class MileageCard extends StatefulWidget {
  final TextTheme textTheme;
  final TextEditingController controller;

  const MileageCard({super.key, required this.textTheme, required this.controller});

  @override
  State<MileageCard> createState() => _MileageCardState();
}

class _MileageCardState extends State<MileageCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutreBlanc,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.speed, size: 24),
            AppSpacers.horizontalSmall,
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок "Пробег"
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).mileage, style: widget.textTheme.subtitleText.copyWith(fontSize: 14)),
                  ),
                  AppSpacers.verticalXSmall,
                  // TextField для ввода пробега
                  TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, MileageInputFormatter(max: 1000000)],
                    decoration: InputDecoration(
                      hintText: S.of(context).enter_mileage,
                      hintStyle: widget.textTheme.hintText.copyWith(fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: InputBorder.none,
                      suffixText: S.of(context).km,
                      suffixStyle: widget.textTheme.hintText.copyWith(fontSize: 16),
                    ),
                    style: widget.textTheme.historyText.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
