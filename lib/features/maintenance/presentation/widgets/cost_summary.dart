import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CostSummary extends StatefulWidget {
  final List<double> servicePricesUah;
  final double manualAmountUah;
  final ValueChanged<double> onManualUahChanged;
  final double Function(double amountUah) convertFromUAH;
  final double Function(double enteredInDisplayCurrency) convertToUAH;
  final String currencyLabel;

  const CostSummary({
    super.key,
    required this.servicePricesUah,
    required this.manualAmountUah,
    required this.onManualUahChanged,
    required this.convertFromUAH,
    required this.convertToUAH,
    required this.currencyLabel,
  });

  @override
  State<CostSummary> createState() => _CostSummaryState();
}

class _CostSummaryState extends State<CostSummary> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _updateControllerFromExternal();
  }

  @override
  void didUpdateWidget(covariant CostSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus) {
      _updateControllerFromExternal();
    }
  }

  void _updateControllerFromExternal() {
    final totalUah = widget.servicePricesUah.fold<double>(0.0, (a, b) => a + b) + widget.manualAmountUah;
    final display = widget.convertFromUAH(totalUah);
    final formatted = display.toStringAsFixed(0);
    if (_controller.text != formatted) {
      _controller.text = formatted;
      _controller.selection = TextSelection.collapsed(offset: formatted.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final totalUah = widget.servicePricesUah.fold<double>(0.0, (a, b) => a + b) + widget.manualAmountUah;
    final displayTotal = widget.convertFromUAH(totalUah);
    final formattedTotal = displayTotal.toStringAsFixed(0);

    return Container(
   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radiusLarge,
        border: Border.all(color: AppColors.grey300, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.attach_money, color: AppColors.blueAccent),
                AppSpacers.horizontalSmallMedium,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).sum),
                    SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                                border: InputBorder.none,
                              ),
                              style: textTheme.black16,
                              onChanged: (val) {
                                final entered = double.tryParse(val) ?? 0.0;
                                // convert from display currency (USD/EUR/UAH) to UAH
                                final manualUah = widget.convertToUAH(entered);
                                widget.onManualUahChanged(manualUah);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(widget.currencyLabel, style: textTheme.black16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacers.horizontalXMassive,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).total_amount),
              Text("$formattedTotal ${widget.currencyLabel}", style: textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
