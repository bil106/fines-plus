import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fines_plus/features/home/presentation/widgets/stat_value.dart';

class StatColumn extends StatelessWidget {
  final Widget icon;
  final String? value;
  final Stream<double>? valueStream;
  final double? fallbackValue;

  final String? label;
  final String Function(double)? labelBuilder;

  const StatColumn({
    super.key,
    required this.icon,
    this.value,
    this.valueStream,
    this.fallbackValue,
    this.label,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        SizedBox(height: 4.h),

        if (valueStream != null)
          StreamBuilder<double>(
            stream: valueStream,
            builder: (context, snapshot) {
              final v = snapshot.data ?? fallbackValue ?? 0;
              return StatValue(value: v.toStringAsFixed(1), label: labelBuilder?.call(v) ?? label ?? '');
            },
          )
        else
          StatValue(value: value ?? '', label: label ?? ''),
      ],
    );
  }
}
