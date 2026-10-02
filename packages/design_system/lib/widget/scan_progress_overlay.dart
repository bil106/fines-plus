import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/widget/overlay_pill.dart';
import 'package:flutter/material.dart';

/// "Scanning..." feedback shown over the screen while a photo is being
/// recognised: a pump icon in a scanning frame and a pill with a spinner.
/// Purely visual - ignores touches; call [dismiss] when recognition ends.
class ScanProgressOverlay {
  ScanProgressOverlay._(this._entry);

  final OverlayEntry? _entry;
  bool _dismissed = false;

  /// Shows nothing (and [dismiss] is a no-op) when the OS asks to reduce motion.
  static ScanProgressOverlay show(BuildContext context, {required String title, required String subtitle}) {
    if (MediaQuery.of(context).disableAnimations) return ScanProgressOverlay._(null);
    final entry = OverlayEntry(builder: (_) => _ScanProgress(title: title, subtitle: subtitle));
    Overlay.of(context, rootOverlay: true).insert(entry);
    return ScanProgressOverlay._(entry);
  }

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _entry?.remove();
  }
}

class _ScanProgress extends StatefulWidget {
  const _ScanProgress({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<_ScanProgress> createState() => _ScanProgressState();
}

class _ScanProgressState extends State<_ScanProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: const Alignment(0, -0.55),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 250),
            builder: (_, value, child) => Opacity(opacity: value, child: child),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScanFrame(controller: _controller, color: primary),
                const SizedBox(width: 12),
                Flexible(
                  child: OverlayPill(
                    leading: SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(strokeWidth: 3, color: primary),
                    ),
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

class _ScanFrame extends StatelessWidget {
  const _ScanFrame({required this.controller, required this.color});

  final Animation<double> controller;
  final Color color;

  static const _size = 64.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppBorders.radiusLarge,
        border: Border.all(color: color, width: 2),
      ),
      child: SizedBox.square(
        dimension: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.local_gas_station_rounded, size: 36, color: AppColors.neutreBlanc.withValues(alpha: 0.9)),
            AnimatedBuilder(
              animation: controller,
              builder: (_, __) => Positioned(
                left: 6,
                right: 6,
                top: 6 + (_size - 16) * Curves.easeInOut.transform(controller.value),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    boxShadow: [BoxShadow(color: color, blurRadius: 8)],
                  ),
                  child: const SizedBox(height: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
