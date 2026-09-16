import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class TrendIcon extends StatelessWidget {
  final bool isUp;

  const TrendIcon({super.key, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, color: isUp ? AppColors.redAccent : AppColors.greenAccent),
      child: Center(
        child: Transform.rotate(
          angle: isUp ? -0.7854 : 0.7854,
          child: Icon(Icons.arrow_forward, size: 26, color: AppColors.white),
        ),
      ),
    );
  }
}
