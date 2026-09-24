import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// The active car's photo on the dashboard hero card, its edges faded into
/// the card so only the car itself reads, not the photo's rectangle. Falls
/// back to the default car icon when there is no photo or it fails to load.
class HeroCarPhoto extends StatelessWidget {
  final String photoUrl;
  final double width;
  final double height;

  const HeroCarPhoto({
    super.key,
    required this.photoUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) return _placeholder();

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const RadialGradient(
        center: Alignment(0, 0.04),
        radius: 0.5,
        transform: _StretchToBounds(),
        colors: [
          AppColors.neutreBlanc,
          AppColors.neutreBlanc,
          Colors.transparent,
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(bounds),
      child: Image.network(
        photoUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Image.asset(
      'assets/icons/car-icon.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

/// Stretches a RadialGradient (sized off the shortest side) horizontally to
/// the full width, so the fade is an ellipse matching the photo's box.
class _StretchToBounds extends GradientTransform {
  const _StretchToBounds();

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final center = bounds.center;
    return Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(bounds.width / bounds.height, 1, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }
}
