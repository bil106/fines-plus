import 'package:design_system/colors/app_colors.dart';
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
                    Text("Пробіг", style: widget.textTheme.subtitleText.copyWith(fontSize: 14)),
                    TextField(
                      controller: widget.controller, // <-- используем внешний
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      showCursor: widget.controller.text.isEmpty,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, MileageInputFormatter(max: 1000000)],
                      decoration: InputDecoration(
                        hintText: "Введіть пробіг",
                        hintStyle: widget.textTheme.hintText.copyWith(fontSize: 16),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: InputBorder.none,
                        suffixText: "км",
                        suffixStyle: widget.textTheme.hintText.copyWith(fontSize: 16),
                      ),
                      style: widget.textTheme.historyText.copyWith(fontSize: 20),
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
}
