import 'package:flutter/material.dart';

/// Drives an endlessly repeating 0..1 animation (rim glare, traffic light)
/// only while its onboarding page is the visible one, so off-screen pages
/// kept alive by the PageView don't burn frames. With system animations
/// turned off it stays still at 0.
class OnboardingLoop extends StatefulWidget {
  const OnboardingLoop({
    super.key,
    required this.duration,
    required this.isActive,
    required this.builder,
  });

  final Duration duration;
  final bool isActive;
  final Widget Function(BuildContext context, Animation<double> loop) builder;

  @override
  State<OnboardingLoop> createState() => _OnboardingLoopState();
}

class _OnboardingLoopState extends State<OnboardingLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(OnboardingLoop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) _sync();
  }

  void _sync() {
    final animate =
        widget.isActive && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
