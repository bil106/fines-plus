import 'dart:ui';

import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Isometric bar chart with a rising trend line, in the look of the old
/// `analytics_bg.png`. Laid out on a 260x200 design box and scaled to
/// [size]; [progress] (0..1, the page's entrance) grows the bars one after
/// another, then draws the line and its arrow.
class OnboardingBarsPainter extends CustomPainter {
  OnboardingBarsPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  static const designSize = Size(260, 200);
  static const _base = 196.0;
  static const _barWidth = 36.0;
  static const _depth = Offset(16, -9);
  static const _bars = [(22.0, 58.0), (80.0, 92.0), (138.0, 124.0), (196.0, 158.0)];
  static const _trend = [
    Offset(4, 182), Offset(44, 134), Offset(86, 142), Offset(118, 100),
    Offset(150, 110), Offset(186, 64), Offset(214, 72), Offset(248, 20),
  ];

  static double _slice(double t, double begin, double end, Curve curve) =>
      curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    canvas.save();
    canvas.scale(size.width / designSize.width, size.height / designSize.height);

    for (var i = 0; i < _bars.length; i++) {
      final begin = 0.1 + i * 0.08;
      final grow = _slice(t, begin, begin + 0.35, Curves.easeOutBack);
      _paintBar(canvas, _bars[i].$1, _bars[i].$2 * grow);
    }
    _paintTrend(canvas, _slice(t, 0.45, 0.75, Curves.easeOutCubic));
    canvas.restore();
  }

  void _paintBar(Canvas canvas, double x, double height) {
    if (height <= 0) return;
    final top = _base - height;
    final front = Rect.fromLTWH(x, top, _barWidth, height);
    final sideTop = Offset(x + _barWidth, top);
    final side = Path()
      ..moveTo(sideTop.dx, sideTop.dy)
      ..relativeLineTo(_depth.dx, _depth.dy)
      ..lineTo(sideTop.dx + _depth.dx, _base + _depth.dy)
      ..lineTo(sideTop.dx, _base)
      ..close();
    final cap = Path()
      ..moveTo(x, top)
      ..relativeLineTo(_depth.dx, _depth.dy)
      ..relativeLineTo(_barWidth, 0)
      ..lineTo(x + _barWidth, top)
      ..close();

    canvas.drawRect(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.isoBarFrontHigh, AppColors.isoBarFrontMid, AppColors.isoBarFrontLow],
          stops: [0, 0.55, 1],
        ).createShader(front),
    );
    canvas.drawPath(
      side,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.isoBarSideHigh, AppColors.isoBarSideMid, AppColors.isoBarSideLow],
          stops: [0, 0.6, 1],
        ).createShader(side.getBounds()),
    );
    canvas.drawPath(cap, Paint()..color = AppColors.isoBarTop);
  }

  void _paintTrend(Canvas canvas, double drawn) {
    if (drawn <= 0) return;
    final line = Path()..moveTo(_trend.first.dx, _trend.first.dy);
    for (final point in _trend.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }
    final bounds = line.getBounds();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [AppColors.trendLineStart, AppColors.trendLineEnd],
      ).createShader(bounds);
    for (final PathMetric metric in line.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * drawn), paint);
    }

    final arrowOpacity = ((drawn - 0.9) / 0.1).clamp(0.0, 1.0);
    if (arrowOpacity > 0) {
      final arrow = Path()
        ..moveTo(254, 10)
        ..lineTo(238, 17)
        ..lineTo(250, 29)
        ..close();
      canvas.drawPath(
        arrow,
        Paint()..color = AppColors.trendLineEnd.withValues(alpha: arrowOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(OnboardingBarsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
