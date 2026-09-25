import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_entrance.dart';
import 'package:flutter/material.dart';

/// One onboarding page: an animated illustration ([heroBuilder]), title,
/// subtitle and CTA. Each time the page becomes [isActive] its entrance
/// replays - illustration, title, subtitle and button rise in one after
/// another and the CTA label cross-fades from [previousLabel]. [swipeDelta]
/// (page offset while swiping, -1..1) slides the illustration at half speed
/// for a parallax effect.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.isActive,
    required this.swipeDelta,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.previousLabel,
    required this.accent,
    required this.onPressed,
    required this.heroBuilder,
  });

  final bool isActive;
  final double swipeDelta;
  final String title;
  final String subtitle;
  final String label;
  final String? previousLabel;
  final Color accent;
  final VoidCallback onPressed;
  final Widget Function(BuildContext context, Animation<double> entrance)
  heroBuilder;

  static const heroSize = 260.0;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  static const _shortHeroSize = 150.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (widget.isActive && _entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive &&
        !oldWidget.isActive &&
        !MediaQuery.disableAnimationsOf(context)) {
      _entrance.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 600;
    final heroSize = isShort ? _shortHeroSize : OnboardingPage.heroSize;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: isShort ? 1 : 60),
              Transform.translate(
                offset: Offset(widget.swipeDelta * size.width * 0.5, 0),
                child: ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: heroSize,
                    child: FittedBox(
                      child: SizedBox.square(
                        dimension: OnboardingPage.heroSize,
                        child: widget.heroBuilder(context, _entrance),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isShort ? 1 : 60),
              _rise(
                begin: 0.08,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: context.brandTheme.displayTextStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              _rise(
                begin: 0.16,
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: textTheme.black16.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: isShort ? 20 : 100),
              _rise(
                begin: 0.24,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accent,
                      foregroundColor: AppColors.neutreBlanc,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: widget.onPressed,
                    child: _buildLabel(textTheme),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rise({required double begin, required Widget child}) =>
      OnboardingEntrance(
        animation: _entrance,
        begin: begin,
        end: begin + 0.4,
        child: child,
      );

  /// The CTA label swaps from the previous page's wording to this page's
  /// (e.g. "Далі" -> "Добре"): the old one lifts out as the new one rises in.
  Widget _buildLabel(TextTheme textTheme) {
    final style = textTheme.black18bold.copyWith(
      fontSize: 15.5,
      fontWeight: FontWeight.w800,
      color: AppColors.neutreBlanc,
    );
    final current = Text(widget.label, style: style);
    final previous = widget.previousLabel;
    if (previous == null || previous == widget.label) return current;

    const swap = Interval(0.3, 0.55, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) {
        final t = swap.transform(_entrance.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1 - t,
              child: Transform.translate(
                offset: Offset(0, -8 * t),
                child: Text(previous, style: style),
              ),
            ),
            Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - t)),
                child: current,
              ),
            ),
          ],
        );
      },
    );
  }
}
