import 'dart:math' as math;

import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:flutter/material.dart';

/// A short celebratory burst (drops, pluses, gauges) with a badge, shown over
/// the whole screen once a camera scan has filled the form. Purely visual:
/// ignores touches and removes itself when finished.
abstract final class ScanRewardOverlay {
  static const _duration = Duration(milliseconds: 2600);

  /// Does nothing when the OS asks to reduce motion.
  static void show(BuildContext context, {required String message}) {
    if (MediaQuery.of(context).disableAnimations) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _RewardAnimation(message: message, onDone: entry.remove),
    );
    overlay.insert(entry);
  }
}

class _RewardAnimation extends StatefulWidget {
  const _RewardAnimation({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<_RewardAnimation> createState() => _RewardAnimationState();
}

class _RewardAnimationState extends State<_RewardAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: ScanRewardOverlay._duration)
        ..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.9),
    );
    final slide = Tween(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.3, curve: Curves.easeOutBack),
      ),
    );
    final fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1), weight: 68),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 20),
    ]).animate(badge);

    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BurstPainter(
                  progress: _controller,
                  primary: Theme.of(context).colorScheme.primary,
                  gold: AppColors.catFuel,
                ),
              ),
            ),
            // Same height as the burst origin, so it is always where the
            // particles are.
            Align(
              alignment: Alignment(0, _BurstPainter.originY * 2 - 1),
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: _Badge(message: widget.message),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppBorders.radius50,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.catFuel),
            const SizedBox(width: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutreBlanc,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Glyph { drop, plus, gauge }

/// One particle: end offset from the burst origin, rotation, start delay.
typedef _Spec = ({
  double dx,
  double dy,
  double turn,
  double delay,
  _Glyph glyph
});

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.primary,
    required this.gold,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color primary;
  final Color gold;

  static const List<_Spec> _specs = [
    (dx: -130, dy: -150, turn: -0.5, delay: 0.00, glyph: _Glyph.drop),
    (dx: -80, dy: -210, turn: 0.3, delay: 0.05, glyph: _Glyph.plus),
    (dx: -20, dy: -240, turn: -0.2, delay: 0.10, glyph: _Glyph.gauge),
    (dx: 50, dy: -220, turn: 0.6, delay: 0.03, glyph: _Glyph.drop),
    (dx: 110, dy: -170, turn: -0.4, delay: 0.08, glyph: _Glyph.plus),
    (dx: 150, dy: -90, turn: 0.3, delay: 0.12, glyph: _Glyph.gauge),
    (dx: -150, dy: -60, turn: 0.7, delay: 0.02, glyph: _Glyph.drop),
    (dx: -110, dy: 60, turn: -0.3, delay: 0.10, glyph: _Glyph.plus),
    (dx: 130, dy: 40, turn: 0.5, delay: 0.06, glyph: _Glyph.gauge),
    (dx: -60, dy: -120, turn: 0.2, delay: 0.15, glyph: _Glyph.drop),
    (dx: 70, dy: -130, turn: -0.7, delay: 0.09, glyph: _Glyph.plus),
    (dx: 10, dy: -180, turn: 0.4, delay: 0.04, glyph: _Glyph.gauge),
  ];

  /// Burst origin as a share of the screen height.
  static const originY = 0.43;

  /// Particle flight length as a share of the whole animation.
  static const _flight = 0.6;
  static const _start = 0.17;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * originY);
    for (var i = 0; i < _specs.length; i++) {
      final spec = _specs[i];
      final t =
          ((progress.value - _start - spec.delay) / _flight).clamp(0.0, 1.0);
      if (t == 0 || t == 1) continue;
      final eased = Curves.easeOut.transform(t);
      final alpha =
          t < 0.2 ? t / 0.2 : (t > 0.55 ? 1 - (t - 0.55) / 0.45 : 1.0);
      final scale = t < 0.55 ? eased * 1.1 : 1.1 - (t - 0.55) * 0.7;
      final center = origin +
          Offset(
              spec.dx * eased,
              spec.dy * eased +
                  (t > 0.55 ? 70 * math.pow((t - 0.55) / 0.45, 2) : 0));
      final color = (i.isEven ? primary : gold).withValues(alpha: alpha);
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(spec.turn * 2 * t)
        ..scale(scale);
      _drawGlyph(canvas, spec.glyph, color);
      canvas.restore();
    }
  }

  void _drawGlyph(Canvas canvas, _Glyph glyph, Color color) {
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    switch (glyph) {
      case _Glyph.drop:
        canvas.drawPath(
          Path()
            ..moveTo(0, -10)
            ..cubicTo(0, -10, -8, 0, -8, 4)
            ..arcToPoint(const Offset(8, 4),
                radius: const Radius.circular(8), clockwise: false)
            ..cubicTo(8, 0, 0, -10, 0, -10),
          fill,
        );
      case _Glyph.plus:
        canvas
          ..drawLine(const Offset(0, -7), const Offset(0, 7), stroke)
          ..drawLine(const Offset(-7, 0), const Offset(7, 0), stroke);
      case _Glyph.gauge:
        canvas
          ..drawArc(Rect.fromCircle(center: Offset.zero, radius: 9), math.pi,
              math.pi, false, stroke)
          ..drawLine(Offset.zero, const Offset(6, -6), stroke);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.primary != primary || old.gold != gold;
}
