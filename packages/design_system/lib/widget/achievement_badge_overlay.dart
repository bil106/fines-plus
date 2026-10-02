import 'dart:math' as math;

import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/widget/overlay_pill.dart';
import 'package:flutter/material.dart';

/// A small trophy badge with sparkles, shown over the whole screen as a
/// reward once data has been saved. Purely visual: ignores touches and
/// removes itself when finished (it lives on the root overlay, so it
/// survives the screen being closed).
abstract final class AchievementBadgeOverlay {
  static const _duration = Duration(milliseconds: 2400);

  /// Does nothing when the OS asks to reduce motion.
  static void show(BuildContext context, {required String title, required String subtitle}) {
    if (MediaQuery.of(context).disableAnimations) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _BadgeAnimation(title: title, subtitle: subtitle, onDone: entry.remove),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _BadgeAnimation extends StatefulWidget {
  const _BadgeAnimation({required this.title, required this.subtitle, required this.onDone});

  final String title;
  final String subtitle;
  final VoidCallback onDone;

  @override
  State<_BadgeAnimation> createState() => _BadgeAnimationState();
}

class _BadgeAnimationState extends State<_BadgeAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AchievementBadgeOverlay._duration)..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.2, curve: Curves.easeOutBack)),
    );
    final fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 18),
    ]).animate(_controller);

    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: const Alignment(0, -0.4),
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: CustomPaint(
                foregroundPainter: _SparklePainter(progress: _controller),
                child: OverlayPill(
                  leading: const Icon(Icons.emoji_events_rounded, color: AppColors.catFuel, size: 32),
                  title: widget.title,
                  subtitle: widget.subtitle,
                  background: AppColors.neutreBlanc,
                  foreground: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Short rays flashing out of both ends of the pill.
class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  static const _rays = [-0.6, 0.0, 0.6];

  @override
  void paint(Canvas canvas, Size size) {
    final t = ((progress.value - 0.1) / 0.4).clamp(0.0, 1.0);
    if (t == 0 || t == 1) return;
    final paint = Paint()
      ..color = AppColors.catFuel.withValues(alpha: 1 - t)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final reach = 10 + 14 * Curves.easeOut.transform(t);
    for (final side in [-1.0, 1.0]) {
      final origin = Offset(size.width / 2 + side * size.width / 2, size.height / 2);
      for (final tilt in _rays) {
        final dir = Offset(math.cos(tilt) * side, math.sin(tilt));
        canvas.drawLine(origin + dir * reach, origin + dir * (reach + 8), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => false;
}
