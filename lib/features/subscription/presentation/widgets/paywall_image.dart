import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paywall artwork. The source PNGs are teal; [hueShift] (degrees) rotates
/// them to the flavor's brand color, so one asset serves every white-label.
class PaywallImage extends StatelessWidget {
  final String asset;
  final double hueShift;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  const PaywallImage({
    super.key,
    required this.asset,
    required this.hueShift,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
    if (hueShift.abs() < 1) return image;
    return ColorFiltered(colorFilter: ColorFilter.matrix(_hueMatrix(hueShift)), child: image);
  }

  /// Same matrix as CSS `hue-rotate()`.
  static List<double> _hueMatrix(double degrees) {
    final radians = degrees * math.pi / 180;
    final cosine = math.cos(radians);
    final sine = math.sin(radians);
    return [
      0.213 + cosine * 0.787 - sine * 0.213,
      0.715 - cosine * 0.715 - sine * 0.715,
      0.072 - cosine * 0.072 + sine * 0.928,
      0, 0,
      0.213 - cosine * 0.213 + sine * 0.143,
      0.715 + cosine * 0.285 + sine * 0.140,
      0.072 - cosine * 0.072 - sine * 0.283,
      0, 0,
      0.213 - cosine * 0.213 - sine * 0.787,
      0.715 - cosine * 0.715 + sine * 0.715,
      0.072 + cosine * 0.928 + sine * 0.072,
      0, 0,
      0, 0, 0, 1, 0,
    ];
  }
}
