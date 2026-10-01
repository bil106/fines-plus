import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/feedback/app_haptics.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/maintenance/data/odometer_scanner.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _scanFailed = false;
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() => _scanFailed = false);

  /// Photographs the dashboard and fills the field with what was read - the
  /// user still sees it and can correct it.
  Future<void> _scan() async {
    final unitStream = UnitStream(context.read<SettingsCubit>());
    final lastKm = context.read<MaintenanceCubit>().getLastKnownMileage();
    final lastDisplay = lastKm == null ? null : unitStream.convert(lastKm.toDouble()).round();
    final scan = await OdometerScanner().readMileage(lastKnown: lastDisplay);
    if (!mounted || scan.cancelled) return;
    final reading = scan.reading;
    if (reading == null) {
      AppHaptics.error();
      setState(() => _scanFailed = true);
      return;
    }
    setState(() => _scanFailed = false);
    final text = formatThousands(reading);
    widget.controller.text = text;
    widget.onChanged?.call(text);
    widget.onSubmitted?.call(text);
  }

  // TextField/InputDecorator don't report a usable intrinsic width (wrapping
  // in IntrinsicWidth still stretches to the row's full available space), so
  // the field's width is measured from its own text to hug the unit label.
  double _textWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: AppColors.neutreBlanc,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.brandTheme.surfaceBorder),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focusNode.requestFocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
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
                          ),
                        ],
                      ),
                      AppSpacers.verticalXSmall,

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Builder(
                            builder: (context) {
                              final valueStyle = widget.textTheme.historyText
                                  .merge(context.brandTheme.moneyTextStyle)
                                  .copyWith(fontSize: 15, color: AppColors.ink);
                              final hintStyle = widget.textTheme.hintText
                                  .copyWith(fontSize: 15);
                              final width = widget.controller.text.isEmpty
                                  ? _textWidth(
                                      S.of(context).enter_mileage,
                                      hintStyle,
                                    )
                                  : _textWidth(
                                          widget.controller.text,
                                          valueStyle,
                                        ) +
                                        2;
                              return Flexible(
                                child: SizedBox(
                                  width: width,
                                  child: TextField(
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
                                      hintStyle: hintStyle,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style: valueStyle,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (widget.unitLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                widget.unitLabel!,
                                style: widget.textTheme.historyText
                                    .merge(context.brandTheme.moneyTextStyle)
                                    .copyWith(
                                      fontSize: 15,
                                      color: AppColors.ink,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      if (_scanFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            S.of(context).odometer_scan_failed,
                            style: widget.textTheme.subtitleText.copyWith(
                              fontSize: 11.5,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _scan,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
