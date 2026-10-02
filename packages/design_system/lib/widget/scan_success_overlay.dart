import 'dart:math' as math;

import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/overlay_pill.dart';
import 'package:flutter/material.dart';

/// Success feedback once a camera scan has filled the form: a check mark with
/// a ring and confetti, and a pill with a short message. Purely visual:
/// ignores touches and removes itself when finished.
abstract final class ScanSuccessOverlay {
  static const _duration = Duration(milliseconds: 2400);

  /// Does nothing when the OS asks to reduce motion.
  static void show(BuildContext context, {required String title, required String subtitle}) {
    if (MediaQuery.of(context).disableAnimations) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SuccessAnimation(title: title, subtitle: subtitle, onDone: entry.remove),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _SuccessAnimation extends StatefulWidget {
  const _SuccessAnimation({required this.title, required this.subtitle, required this.onDone});

  final String title;
  final String subtitle;
  final VoidCallback onDone;

  @override
  State<_SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<_SuccessAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: ScanSuccessOverlay._duration)..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final pop = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.25, curve: Curves.easeOutBack));
    final pill = CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.35, curve: Curves.easeOut));
    final fade = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 20),
    ]).animate(_controller);

    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: fade,
          child: Align(
            alignment: const Alignment(0, -0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 220,
                  child: CustomPaint(
                    painter: _ConfettiPainter(progress: _controller, primary: primary),
                    child: Center(
                      child: ScaleTransition(
                        scale: pop,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            shape: BoxShape.circle,
                            border: Border.all(color: primary, width: 3),
                            boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.6), blurRadius: 24)],
                          ),
                          child: const SizedBox.square(
                            dimension: 88,
                            child: Icon(Icons.check_rounded, size: 56, color: AppColors.neutreBlanc),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: pill,
                  child: OverlayPill(
                    leading: Icon(Icons.check_circle_rounded, color: primary, size: 32),
                    title: widget.title,
                    subtitle: widget.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.primary}) : super(repaint: progress);

  final Animation<double> progress;
  final Color primary;

  static const _count = 16;
  static const _flight = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final t = (progress.value / _flight).clamp(0.0, 1.0);
    if (t == 0 || t == 1) return;
    final eased = Curves.easeOutCubic.transform(t);
    for (var i = 0; i < _count; i++) {
      final angle = i * 2 * math.pi / _count + (i.isOdd ? 0.12 : 0);
      final distance = size.width / 2 * (i.isOdd ? 0.7 : 0.95) * eased;
      final color = (i % 3 == 0 ? primary : i % 3 == 1 ? AppColors.catFuel : AppColors.neutreBlanc)
          .withValues(alpha: 1 - t * t);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        i.isOdd ? 3 : 4.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.primary != primary;
}
