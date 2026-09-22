import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core_utils/formatters/mileageInput_formatter.dart';
import 'package:core_utils/formatters/thousands_separator_formatter.dart';

class MileageCard extends StatefulWidget {
  final TextTheme textTheme;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Unit suffix shown after the value (e.g. "km"/"mil") - matches the
  /// mockup's "128 450 км".
  final String? unitLabel;

  const MileageCard({
    super.key,
    required this.textTheme,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.unitLabel,
  });

  @override
  State<MileageCard> createState() => _MileageCardState();
}

class _MileageCardState extends State<MileageCard> {
  FocusNode? _ownedFocusNode;
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: AppColors.neutreBlanc,
        elevation: 2,
        shadowColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.brandTheme.surfaceBorder),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focusNode.requestFocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.of(context).mileage,
                    style: widget.textTheme.subtitleText.copyWith(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                AppSpacers.verticalXSmall,

                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MileageInputFormatter(max: 1000000),
                    LengthLimitingTextInputFormatter(6),
                    ThousandsSeparatorInputFormatter(),
                  ],
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    hintText: S.of(context).enter_mileage,
                    hintStyle: widget.textTheme.hintText.copyWith(fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    focusedBorder: InputBorder.none,
                    suffixText: widget.unitLabel == null
                        ? null
                        : ' ${widget.unitLabel}',
                    suffixStyle: widget.textTheme.historyText
                        .merge(context.brandTheme.moneyTextStyle)
                        .copyWith(fontSize: 15, color: AppColors.textSecondary),
                  ),
                  style: widget.textTheme.historyText
                      .merge(context.brandTheme.moneyTextStyle)
                      .copyWith(fontSize: 15, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
